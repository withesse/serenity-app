# Session scripts

Editorial source of truth for every guided meditation / sleep story
shipped in the app. One markdown per session, id matches
`LibrarySession.id` so diffs align with code changes.

## Format

Every file has four sections. Don't rearrange — the TTS pipeline reads
them positionally.

```
---
session: <id>              # matches librarySessions
duration: 10 min           # target output length
language: en, zh           # locales to produce
voice: Mei | Aya | Felix | Noah | Soundscape
---

# <Title EN>
# <标题 ZH>

## Brief

1 short paragraph describing the session's emotional arc — not the
words, the shape. Voice actor / TTS operator reads this first.

## Script EN

[pause:3s]       ← pacing cues the TTS stage processes
Take a soft breath in…
[pause:2s]
…and release it slowly.
…

## Script ZH

[pause:3s]
缓缓吸气……
[pause:2s]
再轻轻地吐出来。
…
```

## Pacing cues

`[pause:Ns]` inserts silence. Provider-specific:
- Google Cloud SSML: replace with `<break time="Ns"/>` at export
- Azure SSML: same
- ElevenLabs: replace with a literal `...` dotted ellipsis (they parse it as ~1s each) or use their proprietary `<pause>`
- Human actor: literal direction — read nothing for N seconds

## Emphasis, prosody

Keep it minimal. Meditation scripts read poorly when over-directed.
Use:
- `…` ellipsis for a breath-length hold
- Short sentences — one clause per line
- No SSML `<emphasis>` — flat delivery is the goal

## QA checklist before shipping a file

- [ ] EN and ZH tracks have matching structure (same beats, same number of pauses)
- [ ] No medical claims ("cures insomnia", "treats anxiety")
- [ ] Duration target hits within ±20% at 1x speed
- [ ] No trademarked imagery (Bodhi Tree is fine; "Calm blue" is not)
- [ ] TTS dry-run confirms pronunciation of uncommon words (names, places)
- [ ] `dart run tools/validate_scripts.dart`

## Sample

[`drifting-into-stillness.md`](drifting-into-stillness.md) is the
canonical template — a fully written 10-minute sleep-prep session in
both languages. Use it as the style reference for the rest.
