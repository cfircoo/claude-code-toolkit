#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "google-genai>=1.0.0",
#     "pillow>=10.0.0",
# ]
# ///
"""
Nano Banana image generation script using Google Gemini's image generation model.

Usage:
    uv run ~/.claude/scripts/generate_image.py "prompt" [options]

Options:
    --check-key           Check if API key is set (returns API_KEY_OK or API_KEY_MISSING)
    --output PATH         Output file path (default: generated_image.png)
    --edit IMAGE          Path to source image for editing (enables edit mode)
    --json                Output metadata as JSON instead of formatted text

Environment:
    GEMINI_API_KEY        Required API key (get from https://aistudio.google.com/apikey)
"""

import argparse
import json
import os
import sys
from pathlib import Path

# Handle --check-key early (before heavy imports) so it works without dependencies
if "--check-key" in sys.argv:
    api_key = os.environ.get("GEMINI_API_KEY")
    if api_key:
        print("API_KEY_OK")
        sys.exit(0)
    else:
        print("API_KEY_MISSING")
        sys.exit(1)

from google import genai
from google.genai import types
from PIL import Image
import io

MODEL = "gemini-2.5-flash-image"


def generate_image(
    prompt: str,
    output_path: str = "generated_image.png",
    edit_image_path: str | None = None,
) -> dict:
    """Generate or edit an image using Nano Banana (Gemini image generation)."""

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return {"error": "GEMINI_API_KEY environment variable not set"}

    client = genai.Client(api_key=api_key)
    output = Path(output_path)

    try:
        if edit_image_path:
            # Image editing mode - include source image in contents
            source_path = Path(edit_image_path)
            if not source_path.exists():
                return {"error": f"Source image not found: {edit_image_path}"}

            source_image = Image.open(source_path)
            contents = [prompt, source_image]
        else:
            # Text-to-image generation
            contents = prompt

        response = client.models.generate_content(
            model=MODEL,
            contents=contents,
            config=types.GenerateContentConfig(
                response_modalities=["IMAGE", "TEXT"],
            ),
        )

        # Extract image from response
        if not response.candidates or not response.candidates[0].content.parts:
            return {"error": "No image generated. The model may have refused the prompt."}

        image_saved = False
        text_response = ""

        for part in response.candidates[0].content.parts:
            if part.inline_data and part.inline_data.mime_type.startswith("image/"):
                image = Image.open(io.BytesIO(part.inline_data.data))
                output.parent.mkdir(parents=True, exist_ok=True)
                image.save(str(output))
                image_saved = True
            elif part.text:
                text_response = part.text

        if not image_saved:
            return {"error": "No image data in response. Try rephrasing your prompt."}

        result = {
            "status": "success",
            "output_path": str(output.resolve()),
            "model": MODEL,
            "prompt": prompt,
            "size": f"{image.width}x{image.height}",
        }
        if edit_image_path:
            result["source_image"] = edit_image_path
        if text_response:
            result["text_response"] = text_response

        return result

    except Exception as e:
        error_msg = str(e)
        if "SAFETY" in error_msg.upper() or "BLOCK" in error_msg.upper():
            return {"error": f"Image generation blocked by safety filters: {error_msg}"}
        if "RESOURCE_EXHAUSTED" in error_msg.upper() or "429" in error_msg:
            return {"error": "Rate limit or quota exceeded. Check billing at https://ai.google.dev/gemini-api/docs/rate-limits"}
        return {"error": f"Generation failed: {error_msg}"}


def format_output(data: dict) -> str:
    """Format generation results for readable output."""
    if "error" in data:
        return f"Error: {data['error']}"

    lines = [
        "Image generated successfully!",
        f"  Output: {data['output_path']}",
        f"  Model: {data['model']}",
        f"  Size: {data['size']}",
        f"  Prompt: {data['prompt']}",
    ]
    if "source_image" in data:
        lines.append(f"  Source: {data['source_image']}")
    if "text_response" in data:
        lines.append(f"  Note: {data['text_response']}")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Generate images using Nano Banana (Google Gemini image generation)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("prompt", help="Image generation prompt")
    parser.add_argument(
        "--output", "-o", default="generated_image.png", help="Output file path (default: generated_image.png)"
    )
    parser.add_argument("--edit", metavar="IMAGE", help="Source image path for editing mode")
    parser.add_argument("--json", action="store_true", help="Output metadata as JSON")

    args = parser.parse_args()

    result = generate_image(
        prompt=args.prompt,
        output_path=args.output,
        edit_image_path=args.edit,
    )

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(format_output(result))

    # Exit with error code if generation failed
    if "error" in result:
        sys.exit(1)


if __name__ == "__main__":
    main()
