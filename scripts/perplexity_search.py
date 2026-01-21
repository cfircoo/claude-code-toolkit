#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "requests>=2.28.0",
# ]
# ///
"""
Perplexity Search API helper script for Claude Code research agent.

Usage:
    uv run ~/.claude/scripts/perplexity_search.py "query" [options]
    uv run ~/.claude/scripts/perplexity_search.py "query1" "query2" "query3"

Options:
    --check-key           Check if API key is set (returns API_KEY_OK or API_KEY_MISSING)
    --max-results N       Number of results (1-20, default: 5)
    --country CODE        ISO country code (e.g., US, UK, DE)
    --language CODES      ISO 639-1 codes, comma-separated (e.g., en,fr)
    --domains SITES       Allowlist domains, comma-separated
    --exclude-domains     Denylist domains, comma-separated
    --max-tokens N        Total content budget (default: 25000)
    --max-tokens-page N   Per-page content limit (default: 2048)
    --json                Output raw JSON instead of formatted text

Environment:
    PERPLEXITY_API_KEY    Required API key
"""

import argparse
import json
import os
import sys
from typing import Optional

# Handle --check-key early (before requests import) so it works without dependencies
if "--check-key" in sys.argv:
    api_key = os.environ.get("PERPLEXITY_API_KEY")
    if api_key:
        print("API_KEY_OK")
        sys.exit(0)
    else:
        print("API_KEY_MISSING")
        sys.exit(1)

import requests


def search_perplexity(
    queries: list[str],
    max_results: int = 5,
    country: Optional[str] = None,
    language: Optional[list[str]] = None,
    domains: Optional[list[str]] = None,
    exclude_domains: Optional[list[str]] = None,
    max_tokens: int = 25000,
    max_tokens_per_page: int = 2048,
) -> dict:
    """Execute search via Perplexity API."""

    api_key = os.environ.get("PERPLEXITY_API_KEY")
    if not api_key:
        return {"error": "PERPLEXITY_API_KEY environment variable not set"}

    # Build domain filter (allowlist or denylist, not both)
    domain_filter = None
    if domains:
        domain_filter = domains
    elif exclude_domains:
        domain_filter = [f"-{d}" for d in exclude_domains]

    # Use sonar model for search
    url = "https://api.perplexity.ai/chat/completions"

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }

    all_results = []

    for query in queries:
        payload = {
            "model": "sonar",
            "messages": [
                {
                    "role": "system",
                    "content": "You are a research assistant. Provide factual, well-sourced answers with citations."
                },
                {
                    "role": "user",
                    "content": query
                }
            ],
            "max_tokens": max_tokens_per_page,
            "return_citations": True,
            "return_related_questions": True
        }

        # Add search domain filter if specified
        if domain_filter:
            payload["search_domain_filter"] = domain_filter[:20]  # Max 20 domains

        # Add recency filter for fresh results
        payload["search_recency_filter"] = "month"

        try:
            response = requests.post(url, headers=headers, json=payload, timeout=30)
            response.raise_for_status()
            data = response.json()

            result = {
                "query": query,
                "answer": data.get("choices", [{}])[0].get("message", {}).get("content", ""),
                "citations": data.get("citations", []),
                "related_questions": data.get("related_questions", [])
            }
            all_results.append(result)

        except requests.exceptions.RequestException as e:
            all_results.append({
                "query": query,
                "error": str(e)
            })

    return {"results": all_results}


def format_output(data: dict) -> str:
    """Format search results for readable output."""
    if "error" in data:
        return f"Error: {data['error']}"

    output = []

    for result in data.get("results", []):
        output.append(f"\n{'='*60}")
        output.append(f"Query: {result.get('query', 'N/A')}")
        output.append('='*60)

        if "error" in result:
            output.append(f"Error: {result['error']}")
            continue

        output.append(f"\n{result.get('answer', 'No answer')}")

        citations = result.get("citations", [])
        if citations:
            output.append("\n--- Sources ---")
            for i, cite in enumerate(citations, 1):
                if isinstance(cite, str):
                    output.append(f"[{i}] {cite}")
                elif isinstance(cite, dict):
                    output.append(f"[{i}] {cite.get('url', cite)}")

        related = result.get("related_questions", [])
        if related:
            output.append("\n--- Related Questions ---")
            for q in related[:3]:
                output.append(f"  • {q}")

    return "\n".join(output)


def main():
    parser = argparse.ArgumentParser(
        description="Search the web using Perplexity API",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("queries", nargs="*", help="Search queries (1-5)")
    parser.add_argument("--max-results", type=int, default=5, help="Results per query (1-20)")
    parser.add_argument("--country", help="ISO country code (e.g., US, UK)")
    parser.add_argument("--language", help="ISO 639-1 codes, comma-separated")
    parser.add_argument("--domains", help="Allowlist domains, comma-separated")
    parser.add_argument("--exclude-domains", help="Denylist domains, comma-separated")
    parser.add_argument("--max-tokens", type=int, default=25000, help="Total content budget")
    parser.add_argument("--max-tokens-page", type=int, default=2048, help="Per-page limit")
    parser.add_argument("--json", action="store_true", help="Output raw JSON")

    args = parser.parse_args()

    # Require at least one query
    if not args.queries:
        parser.error("At least one search query is required")

    # Limit to 5 queries
    queries = args.queries[:5]

    # Parse comma-separated options
    language = args.language.split(",") if args.language else None
    domains = args.domains.split(",") if args.domains else None
    exclude_domains = args.exclude_domains.split(",") if args.exclude_domains else None

    results = search_perplexity(
        queries=queries,
        max_results=min(args.max_results, 20),
        country=args.country,
        language=language,
        domains=domains,
        exclude_domains=exclude_domains,
        max_tokens=args.max_tokens,
        max_tokens_per_page=args.max_tokens_page,
    )

    if args.json:
        print(json.dumps(results, indent=2))
    else:
        print(format_output(results))


if __name__ == "__main__":
    main()
