# Session narration licenses

One entry per mp3 under `assets/audio/`. Covers the currently-bundled
`meditation_placeholder.mp3` (10 minutes of silence) and every real
narration that replaces it.

---

## meditation_placeholder

- **File**: assets/audio/meditation_placeholder.mp3
- **Kind**: placeholder silence
- **Source**: self-generated (ffmpeg)
- **URL**: n/a
- **Author**: Serenity (work-for-hire)
- **License**: CC0 (self-generated silence)
- **Attribution line**: not required
- **Acquired**: 2026-04-20
- **Proof**: n/a — silence is silence
- **Notes**: bundled so the audio pipeline (just_audio, MediaItem lock-screen) exercises end-to-end without licensed content. Replace per session before GA.

---

<!-- Template — copy this block for every real session recording -->

<!--
## <session-id, e.g. drifting-into-stillness>

- **File**: assets/audio/<session-id>.mp3
- **Kind**: narration (guided meditation / sleep story)
- **Source**: ElevenLabs / Google Cloud TTS / Azure Neural TTS / Voices.com actor / self-recorded
- **URL**: <project URL in the TTS console, or voice actor profile, or n/a for self-recorded>
- **Author**: <voice / actor handle>
- **License**: Google Cloud TOS (commercial) / Azure Cognitive TOS (commercial) / Work for hire (signed contract) / Self-owned
- **Attribution line**: not required (commercial TTS typically exempts) / required: "..."
- **Acquired**: YYYY-MM-DD
- **Proof**: assets/licenses/_proofs/<session-id>-narration.<pdf|png>
- **Notes**: voice name, voice model version, total billed characters, script version used
-->
