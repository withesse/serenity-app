# Visual asset licenses

App icon, session cover art, marketing screenshots background imagery.
Currently the app icon is the only live bundled visual; covers are
gradient placeholders driven by `LibrarySession.gradient`.

---

## app-icon

- **File**: assets/branding/icon.png (1024×1024 source) + generated launcher sets
- **Kind**: app icon
- **Source**: self-generated (tools/generate_icon.py)
- **URL**: n/a
- **Author**: Serenity (work-for-hire)
- **License**: self-owned
- **Attribution line**: not required
- **Acquired**: 2026-04-20
- **Proof**: n/a — source script committed
- **Notes**: golden crescent + starfield on violet gradient; regenerate via `dart run flutter_launcher_icons` after edits

---

<!-- Template for per-session cover art once added -->

<!--
## cover-drifting-into-stillness

- **File**: assets/covers/drifting-into-stillness.jpg
- **Kind**: session cover art
- **Source**: Midjourney / Stable Diffusion local / Unsplash / self-drawn
- **URL**: <prompt / original page>
- **Author**: <operator / photographer>
- **License**: Midjourney paid subscriber (commercial) / SD self-hosted / Unsplash License …
- **Attribution line**: not required (Midjourney paid) / "Photo by <name> on Unsplash" (preferred, not required)
- **Acquired**: YYYY-MM-DD
- **Proof**: assets/licenses/_proofs/cover-drifting-into-stillness-source.png
- **Notes**: prompt text, seed, dimensions, resize strategy
-->

## Reliable free-commercial pools

- **Unsplash**, **Pexels**, **Pixabay** — photography + illustrations, commercial OK, attribution appreciated but optional
- **Lexica.art** — free tier generates SD images, check per-image license
- **Stable Diffusion self-hosted** (A1111, ComfyUI, Draw Things on Mac) — generate and own outright
- **Midjourney paid** — paid subscribers own commercial rights to generations (v5+)

## AI-image flags for App Store

Apple does not yet require AI disclosure but may in the future. Keep
each cover's prompt + seed in `Notes:` so re-generation is deterministic
if a legal team asks later.
