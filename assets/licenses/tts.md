# TTS-generated audio — license notes

The audio files themselves go in `session-audio.md`. This file explains
which upstream TOS applies to the final mp3 depending on how it was
generated, so the right **License** line can be filled in there.

## Who owns the output

| Provider | Owner of output | Attribution required | App Store / commercial app OK | Notes |
|---|---|---|---|---|
| **Google Cloud Text-to-Speech** | You | No | Yes | Free tier: 1M std chars/mo + 1M WaveNet/Neural2 chars/mo. Commercial OK per [Google Cloud TOS](https://cloud.google.com/text-to-speech/pricing). |
| **Microsoft Azure Neural TTS** | You | No | Yes | Free tier: 500k neural chars/mo. Requires acknowledging voice isn't impersonating a real person. |
| **ElevenLabs Free** | You for personal, **no commercial** | n/a | **No** on free tier | Free outputs explicitly cannot be used in monetised apps. Starter+ tiers do allow commercial. |
| **ElevenLabs Creator+** ($22/mo) | You | No | Yes | 100k chars/mo, commercial OK, non-human voices |
| **Volcengine (火山引擎 语音合成)** | You (per per-seat contract) | Yes on some plans | Yes with Commercial plan | 国内商用需签发行方主体合同 |
| **Aliyun Smart Voice** | You | Yes | Yes | Same as above |
| **iFlytek 讯飞** | You | Yes | Yes | License requires per-deployment SN |
| **Coqui TTS (self-hosted, OSS)** | You | No | Yes | MPL-2.0, voice model licenses vary — check each `.pth` |
| **Piper TTS (self-hosted, OSS)** | You | No | Yes | Permissively licensed, voice files mostly CC0 / MIT |
| **Bark (suno-ai, self-hosted)** | You | No | Yes but quality risk | MIT; voice presets shipped with the repo are OK commercially |

## Workflow

1. Write the script in `docs/content-scripts/<session-id>.md`.
2. Feed to the chosen provider. Keep provider screenshot of settings
   (voice id, rate, pitch) in `_proofs/<session-id>-tts-settings.png`.
3. Export mp3 at 44.1kHz, 128kbps mono. Save as
   `assets/audio/<session-id>.mp3`.
4. Add the entry to `session-audio.md`. Fill `License` with the row
   above that matches, `Notes` with voice id + character count.

## What makes a TTS mp3 non-commercial

Common trap: the **voice** can be restricted even when the engine is
permissive. Examples:
- ElevenLabs "stock voices" — OK commercially on paid tiers
- ElevenLabs "voice clones of real people" — requires signed consent
  even on paid tiers
- Coqui TTS pre-trained voices — each trained on a dataset with its own
  license; check `TRAINING_CORPUS` in the voice model card
- Provider "demo voice" or "trial voice" marked with a watermark — never
  commercial

When in doubt, pick a voice the provider explicitly lists as
"royalty-free commercial".
