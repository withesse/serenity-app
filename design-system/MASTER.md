# Serenity — Design System MASTER

> Single source of truth for the Serenity meditation app.
> Visual Direction: **Deep Starry Sky + Glassmorphism**.
> All page-level files under `pages/` only declare *overrides*.

---

## 1. Vision & Mood

Bring the calm of a clear night sky into the user's pocket. The product should feel like opening a window onto the cosmos — quiet, expansive, softly luminous. Every surface earns its brightness. Motion is slow, breath-aligned, never demanding attention.

- **Adjectives**: serene, spacious, nocturnal, luminous, contemplative
- **Avoid**: loud, gamified, neon, saturated, urgent

---

## 2. Color System

### Base (Night Sky Gradient)

| Token | Hex | Usage |
|---|---|---|
| `bg.deep` | `#0B1426` | Bottom of gradient, true-dark reference |
| `bg.mid` | `#1A1B3A` | Mid-gradient transition |
| `bg.top` | `#2D1B4E` | Top of gradient, purple nebula |

**Primary background is a vertical gradient: `bg.top` → `bg.mid` → `bg.deep`.** Never use flat black.

### Brand

| Token | Hex | Usage |
|---|---|---|
| `brand.violet` | `#6B5FD9` | Primary action, selected states |
| `brand.violet-light` | `#8B7FEB` | Hover, highlight |
| `brand.gold` | `#E8C547` | Accent — crescent moon, premium, achievements |
| `brand.aurora-start` | `#6366F1` | Aurora gradient start |
| `brand.aurora-mid` | `#A855F7` | Aurora mid |
| `brand.aurora-end` | `#EC4899` | Aurora end (rare emotional moments only) |

### Surface (Glass)

| Token | Value | Usage |
|---|---|---|
| `surface.glass` | `rgba(255,255,255,0.06)` + blur 20 | Cards, list rows |
| `surface.glass-elevated` | `rgba(255,255,255,0.10)` + blur 24 | Modals, bottom sheets |
| `surface.border` | `rgba(255,255,255,0.12)` | 1px border on all glass |
| `surface.border-strong` | `rgba(255,255,255,0.20)` | Focus / selected |

### Text

| Token | Value | Usage |
|---|---|---|
| `text.primary` | `#F5F3FF` (Starlight) | Headings, primary body |
| `text.secondary` | `rgba(245,243,255,0.72)` | Supporting text |
| `text.tertiary` | `rgba(245,243,255,0.48)` | Placeholders, disabled |
| `text.on-brand` | `#0B1426` | Text on gold button |

### Semantic

| Token | Hex | |
|---|---|---|
| `success` | `#A7F3D0` | Completed session, streak |
| `warning` | `#FDE68A` | Gentle reminders |
| `error` | `#F87171` | True errors only |

---

## 3. Typography

Runtime loaded via `google_fonts` package.

| Role | Family | Weights |
|---|---|---|
| Display / Heading | **Playfair Display** | 300, 500, 700 |
| Body / UI | **Inter** | 300, 400, 500, 600 |
| Numeric / Timer | **Outfit** | 300, 400 (tabular) |

### Type Scale

| Token | Size / Line | Family | Weight | Usage |
|---|---|---|---|---|
| `display.lg` | 40 / 48 | Playfair | 300 | Hero moments, onboarding |
| `display.md` | 32 / 40 | Playfair | 300 | Screen titles |
| `headline` | 24 / 32 | Playfair | 500 | Section headers |
| `title` | 18 / 26 | Inter | 600 | Card titles |
| `body.lg` | 16 / 24 | Inter | 400 | Primary content |
| `body.md` | 14 / 22 | Inter | 400 | Secondary content |
| `label` | 12 / 16 | Inter | 500 (tracked +0.3) | Buttons, chips |
| `timer` | 64 / 64 | Outfit | 300 | Meditation timer |
| `duration` | 18 / 24 | Outfit | 400 | Session length badges |

---

## 4. Spacing (8pt grid)

| Token | px |
|---|---|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 16 |
| `lg` | 24 |
| `xl` | 32 |
| `2xl` | 48 |
| `3xl` | 64 |

Screen horizontal padding: `lg` (24). Vertical section gap: `2xl` (48).

---

## 5. Radius

| Token | px | Usage |
|---|---|---|
| `r.sm` | 8 | Chips, small buttons |
| `r.md` | 16 | Inputs, list items |
| `r.lg` | 24 | Cards |
| `r.xl` | 32 | Hero cards, bottom sheets |
| `r.pill` | 999 | Primary CTA |

No hard corners anywhere. Minimum 8.

---

## 6. Shadows & Glow

Dark surfaces do not use traditional shadows — use **colored glow**.

| Token | Value |
|---|---|
| `glow.soft` | `0 8 24 rgba(107,95,217,0.20)` |
| `glow.strong` | `0 16 48 rgba(107,95,217,0.32)` |
| `glow.gold` | `0 0 32 rgba(232,197,71,0.28)` |
| `glow.aurora` | Multi-stop radial with violet + pink |

---

## 7. Glass Recipe (apply to all Card surfaces)

```
background:      surface.glass
backdrop-filter: blur(20px)
border:          1px solid surface.border
border-radius:   r.lg (24)
shadow:          glow.soft
```

Flutter implementation uses `BackdropFilter` + `Container` with gradient border.

---

## 8. Motion

| Purpose | Duration | Curve |
|---|---|---|
| Interactive (tap, hover) | 200 ms | `easeOutCubic` |
| Page transition | 400 ms | `cubic-bezier(0.2, 0.8, 0.2, 1)` |
| Modal / sheet | 320 ms | `easeOutExpo` |
| Breathing loop | 4000 ms | `easeInOutSine` |
| Star twinkle | 2400–4800 ms | randomised ease |
| Aurora drift | 12000 ms | linear, infinite |

**Reduced motion**: respect `MediaQuery.disableAnimations` — replace loops with static states, keep fades only.

---

## 9. Iconography

- Use `lucide_icons` (stroke 1.5) as baseline.
- Custom SVG only for: moon phases, breath visualizer, constellation shapes.
- Never use emoji in UI.
- Icon size: 20 (inline), 24 (button), 28 (nav), 48 (empty state).

---

## 10. Components (canonical)

### `GlassCard`
- Applies full glass recipe.
- Optional `glow` prop: `none | soft | gold`.

### `AuroraBackground`
- Full-screen gradient + animated radial nebula.
- Placed behind every root scaffold.

### `StarField`
- Layer of twinkling point stars (2–3 layers, parallax on scroll).
- Density prop: `sparse | normal | dense`.

### `PillButton` (primary)
- Height 56, radius pill, gradient fill violet→aurora-start.
- Label: Inter 600 size 16, letter-spacing +0.3.

### `GhostButton` (secondary)
- Glass surface, border, text only.

### `BottomNav`
- Glass elevated surface, 4 tabs: Home · Library · Breathe · Profile.
- Active tab: violet glow under icon, label in `text.primary`.

### `SessionTimer`
- Circular progress ring (violet stroke, gold tick).
- Outfit numeric display center.

---

## 11. Anti-patterns (DO NOT)

- ❌ Pure `#000000` — too harsh, breaks depth
- ❌ Flat design without glass/glow — visually empty at night
- ❌ Light-mode toggle — product is intentionally dark-only
- ❌ Emoji as functional icons
- ❌ Square buttons / hard 90° corners
- ❌ Bright / saturated accent color on primary actions (reserve saturation for moments of emotional reward)
- ❌ Animations > 500 ms for non-loop interactions
- ❌ Red/warning colors outside true error states
- ❌ Gamified streaks (no confetti, no fireworks — this app is not a game)

---

## 12. Pre-delivery Checklist (per screen)

- [ ] Screen uses `AuroraBackground` as root
- [ ] All cards use `GlassCard` with correct glow
- [ ] Typography tokens used — no raw `TextStyle(fontSize: ...)`
- [ ] Color tokens used — no raw `Color(0x...)`
- [ ] Text contrast ≥ 4.5:1 on actual gradient (not just on mid-stop)
- [ ] Tap targets ≥ 44×44
- [ ] Safe area respected (top + bottom)
- [ ] Haptic feedback on primary actions (iOS)
- [ ] Works at 320px width (small Android)
- [ ] Reduced motion respected
- [ ] No emoji, no pure black, no hard corners
