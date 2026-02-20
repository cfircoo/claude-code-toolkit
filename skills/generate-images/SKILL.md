---
name: generate-images
description: Generate and edit images using Nano Banana (Google Gemini image generation). Use whenever Claude Code needs to create new images, edit existing images, generate icons, diagrams, mockups, or any visual content.
---

<essential_principles>

This skill generates images using the Nano Banana model via `~/.claude/scripts/generate_image.py`.

**Always use this skill when the user asks to:**
- Generate, create, or make an image
- Create icons, logos, banners, or visual assets
- Edit, modify, or transform an existing image
- Generate mockups, diagrams, or illustrations
- Create any visual content

**Prerequisites:**
- `GEMINI_API_KEY` must be set in `~/.claude/settings.json` under `env`
- Script: `~/.claude/scripts/generate_image.py` (runs via `uv run`)

</essential_principles>

<process>

<step name="1_check_api_key">
Before generating, verify the API key is available:

```bash
uv run ~/.claude/scripts/generate_image.py --check-key
```

If `API_KEY_MISSING`: inform the user they need to set `GEMINI_API_KEY` in `~/.claude/settings.json` or get one at https://aistudio.google.com/apikey
</step>

<step name="2_determine_output_path">
Choose an appropriate output path based on context:

- If user specifies a path, use it
- If inside a project, use a sensible location (e.g., `assets/`, `images/`, `public/`, or project root)
- Default filename: descriptive kebab-case with `.png` extension (e.g., `hero-banner.png`, `app-icon.png`)
</step>

<step name="3_craft_prompt">
Write an effective image prompt. Good prompts include:

- **Subject**: What to generate (e.g., "a minimalist logo of a rocket")
- **Style**: Visual style (e.g., "flat design", "photorealistic", "watercolor", "pixel art")
- **Details**: Specific attributes (colors, lighting, composition, mood)
- **Quality**: Resolution hints (e.g., "high detail", "4K quality", "professional")

Example prompt structure: `[Subject], [style], [details], [quality]`
</step>

<step name="4_generate">
Run the generation script:

**Text-to-image (new image):**
```bash
uv run ~/.claude/scripts/generate_image.py "prompt here" --output path/to/output.png
```

**Image editing (modify existing):**
```bash
uv run ~/.claude/scripts/generate_image.py "editing instructions" --edit path/to/source.png --output path/to/output.png
```

**Options:**
- `--output PATH` - Output file path (default: `generated_image.png`)
- `--edit IMAGE` - Source image for editing mode
- `--json` - Output metadata as JSON
</step>

<step name="5_verify">
After generation:

1. Read the output image using the Read tool to verify it was created and looks correct
2. Report the file path and size to the user
3. If the result doesn't match expectations, refine the prompt and regenerate
</step>

</process>

<prompt_examples>

**Icon/Logo:**
"A minimalist app icon for a task management tool, flat design, blue and white color scheme, clean geometric shapes, centered composition, professional quality"

**Banner/Hero:**
"Wide panoramic banner for a tech blog, abstract gradient background in purple and teal, modern typography space on the left, subtle geometric patterns, professional web design"

**Product Photo:**
"Professional product photography of a coffee mug on a marble surface, soft studio lighting, shallow depth of field, warm tones, commercial quality"

**Diagram/Technical:**
"Clean technical architecture diagram showing microservices, boxes connected by arrows, white background, professional documentation style, clear labels"

**Edit Example:**
"Remove the background and replace with a gradient from blue to purple" (with --edit flag)

</prompt_examples>

<success_criteria>
Image generation is complete when:

- API key check passes
- Image is saved to the specified output path
- Output image has been visually verified via Read tool
- User is informed of the file location
</success_criteria>
