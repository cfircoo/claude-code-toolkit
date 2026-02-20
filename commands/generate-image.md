---
description: Generate or edit images using Nano Banana (Gemini image generation)
argument-hint: [prompt or description]
allowed-tools: Skill(generate-images), Bash, Read, Write
---

<objective>
Generate an image using the generate-images skill.

Invoke the generate-images skill to create: $ARGUMENTS
</objective>

<context>
Current directory: !`pwd`
API key status: !`uv run ~/.claude/scripts/generate_image.py --check-key 2>/dev/null || echo "SCRIPT_NOT_FOUND"`
</context>

<process>
1. Check API key availability
2. Determine output path and craft prompt from user arguments
3. Generate the image using the script
4. Verify and display the result
</process>

<success_criteria>
- Image generated and saved to disk
- Output path reported to user
- Image verified via Read tool
</success_criteria>
