# Kamioto Brand Foundation

## Brand

**Name:** Kamioto  
**Wordmark:** KAMIOTO  
**Tagline:** Your music. Everywhere.  
**Category:** Personal music player for iPhone, iPad, and connected music libraries.

Kamioto is a modern music player built around the idea that a listener's music should feel at home wherever it lives. The identity combines quiet Japanese-inspired restraint with the warmth and movement of sound. It should feel considered, expressive, and trustworthy—not ornamental, loud, or tied to a short-lived trend.

The name is a coined brand name inspired by *oto* (音, sound). Do not present “Kamioto” as a literal Japanese dictionary word or make unsupported cultural claims.

## Brand principles

1. **Harmony** — balanced layouts, measured contrast, and calm visual rhythm.
2. **Flow** — visual references to sound and continuity, never distracting waveform decoration.
3. **Clarity** — legible typography, clear hierarchy, and controls that remain obvious.
4. **Depth** — a dark, immersive listening surface balanced by warm light surfaces.
5. **Freedom** — the listener's music and chosen services remain central.

## Logo direction

The primary concept is a circular sunrise over layered sound waves:
- a warm orange sun;
- deep navy wave lines;
- a simple, balanced circular silhouette;
- a separate wordmark set in uppercase with generous tracking.

The mark must remain recognizable without the wordmark, at small app-icon sizes, and in monochrome. Avoid literal torii gates, cherry blossoms, kanji used as decoration, headphones, musical notes, and generic equalizer bars.

Required logo variants:
- primary horizontal lockup;
- standalone symbol;
- light-background and dark-background versions;
- one-colour version;
- small-size simplified symbol.

The generated concept board is exploratory direction, not production artwork. Rebuild final assets as clean vector artwork and verify optical alignment and small-size legibility before shipping.

## Colour palette

| Token | Hex | Role |
|---|---|---|
| Sunset Orange | `#FF6B3D` | Primary accent, active controls, highlights |
| Warm Sand | `#F5E9DA` | Warm light surfaces |
| Mist Gray | `#E6E8EC` | Neutral light surfaces and separators |
| Deep Navy | `#0F172A` | Primary dark surface and text |
| Ocean Slate | `#334155` | Secondary dark surfaces and muted text |
| Sage Green | `#4BA3A1` | Secondary accent, success and calm states |

Use Sunset Orange sparingly for interaction and emphasis. Do not use the full palette at once. Maintain accessible contrast for text and controls; validate actual foreground/background pairs before implementation. Semantic status colours must remain distinguishable from brand decoration.

## Typography

Preferred direction:
- **Display / wordmark:** a clean geometric sans with open counters and restrained tracking. Satoshi is a visual reference, subject to confirming its licence and bundling requirements.
- **Interface and body:** Inter or the platform system font. Prefer the native iOS system font for controls and dynamic type unless a custom face demonstrably improves the experience.

Do not bake the wordmark into UI text as an image where accessible text is appropriate.

## Product expression

- Listening screens may use Deep Navy for an immersive, low-glare presentation.
- Library and settings screens prioritize scanability and native iOS conventions.
- Artwork remains the visual hero; brand elements should frame it rather than compete with it.
- Motion should be subtle and tied to playback state. Avoid decorative animation that consumes attention or battery.
- The interface must support light and dark appearances and Dynamic Type.

## Naming and technical boundaries

The customer-facing product name is **Kamioto**. Replace customer-facing “Orioto” and legacy “Mozz” branding in app display strings, marketing copy, documentation, screenshots, and release metadata as each surface is intentionally updated.

**Do not rename internal technical identifiers as part of this rebrand.** Preserve:
- Swift modules and package products such as `MozzKit`, `MozzCore`, `MozzPlayback`, and the other `Mozz*` modules;
- Rust crate names and FFI symbols;
- source directories, target names, and Objective-C runtime names unless a separate technical migration is explicitly approved;
- existing Bundle ID, App Group identifiers, database names, persisted keys, and on-disk paths.

Do not perform a blind global search-and-replace. Customer-facing strings must be distinguished from identifiers, compatibility contracts, and persisted data.

## Acceptance checklist

- [ ] Final vector logo and app icon supplied in light and dark variants.
- [ ] App icon tested at small sizes and against iOS appearance variants.
- [ ] Splash / launch screen uses the approved mark and palette.
- [ ] App display name is Kamioto.
- [ ] Onboarding, settings, accessibility labels, and user-visible copy use Kamioto consistently.
- [ ] README, repository description, documentation, and release copy use Kamioto.
- [ ] No internal `Mozz*` module, crate, FFI, Bundle ID, App Group, or persistence identifier was renamed.
- [ ] Contrast, Dynamic Type, light/dark appearance, and localisation are checked.
