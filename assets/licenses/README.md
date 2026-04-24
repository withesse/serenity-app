# Asset Licenses

Every third-party asset bundled into the app or used in marketing gets one
entry in the right file below, checked in at the same time as the asset
itself. This is the single source of truth for App Store / Play review
and for any future DMCA response.

## Files

| File | Covers |
|---|---|
| `session-audio.md` | Guided meditation + sleep story narrations (mp3 under `assets/audio/`) |
| `soundscapes.md` | Ambient loops (rain, forest, ocean, fire, crickets, etc.) |
| `music.md` | Background bed music, pads, ambient tracks |
| `visuals.md` | Cover art, icon sources, photography |
| `tts.md` | Notes on TTS-generated audio (whose terms apply when the voice is synthetic) |

## Per-entry format

Use this skeleton for every row. Keep the source URL even if the page
later moves — the Wayback Machine is often the last line of defence.

```
## <asset-id>

- **File**: assets/audio/<filename>.mp3   ← path inside repo, or "(marketing only)"
- **Kind**: narration / soundscape / music / image
- **Source**: Freesound / Zapsplat / ElevenLabs / Google TTS / self-recorded …
- **URL**: https://… (original page — exact track, not the site homepage)
- **Author**: <name or handle>
- **License**: CC0 / CC BY 4.0 / Pixabay / Freesound Standard / Work for hire / Commercial (paid) …
- **Attribution line**: "<exact text the license requires>", or "not required"
- **Acquired**: YYYY-MM-DD
- **Proof**: assets/licenses/_proofs/<screenshot.png>  ← license page screenshot / receipt / contract PDF
- **Notes**: (anything unusual — derivative rights, territorial limits, expiry)
```

## _proofs/

Put license-page screenshots, receipt PDFs, signed voice-actor contracts,
and similar here. Filename convention: `<asset-id>-<kind>.<ext>`. Keep them
in the repo — they're small, and losing them means losing the defence.

## Attribution page in-app

If any entry's attribution line is non-empty, surface the combined list
in `Profile → Settings → About → Credits`. Settings has a spot reserved
for this — it's currently empty; wire it once there's a non-empty entry
to display.

## 中文合规补充

上架国内应用商店（App Store 中国区、各安卓市场）时：
- 版权页需要能在中文环境里显示
- 每条素材如果来自国外站点，保留协议原文链接足够
- 国内 TTS 供应商（火山 / 阿里 / 讯飞）的商用条款要和发行主体签名，截图入库
