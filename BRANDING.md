# Kami Brand Foundation

## Brand architecture

**Family:** Kami  
**First product:** Kamioto — music player and audio library  
**Possible future product:** Kamiei — video player and video library

Kami is the shared identity system, not necessarily a customer-facing app name. Kamioto and any future Kamiei product should feel like members of one family while remaining immediately distinguishable in an app grid.

The family resemblance must come from a shared visual grammar—material, geometry, typography, colour logic, lighting, and motion—not from reusing one identical app icon with different labels.

Do not design Kamiei's product experience now. Its possible existence is a compatibility constraint for Kamioto's identity work.

## Brand idea

**Core idea:** form created by folding; movement created by unfolding.

The identity should feel warm, tactile, quiet, contemporary, and expressive. Paper is the material inspiration and origami is the underlying design principle, but the brand must not rely on literal origami objects or obvious Japanese clichés.

The visual language should communicate transformation: a flat surface becomes volume, a fold becomes a path, and a path becomes movement. This can connect music and video without depicting either medium literally.

The name Kamioto is a coined brand name inspired by *oto* (音, sound). Do not present “Kamioto” as a literal Japanese dictionary word or make unsupported cultural claims. Do not invent a linguistic meaning for “Kamiei”.

## Brand principles

1. **Warmth** — tactile paper, soft light, restrained earthy colour, and a welcoming tone.
2. **Transformation** — simple surfaces become expressive forms through folds and continuous movement.
3. **Flow** — continuity and rhythm without generic waveform decoration.
4. **Clarity** — legible typography, clear hierarchy, and controls that remain obvious.
5. **Freedom** — the user's own media and chosen services remain central.

## Shared visual grammar

### Form

Explore three related directions:
- **The Fold:** a single sheet transformed by one precise, distinctive fold. Geometric, compact, and legible at small sizes.
- **Unfold:** a continuous paper ribbon or strip that changes direction in one fluid gesture. Organic, dynamic, and expressive.
- **Fold to Unfold:** a hybrid in which a crisp fold transitions into a flowing line. This is the leading candidate for a family-level symbol because it can express both structure and motion.

These are exploration routes, not approved final artwork. Avoid shapes that accidentally read as birds, cranes, boats, generic infinity symbols, or stock abstract ribbons. Do not force a K-shaped monogram.

### Family relationship

Kamioto and a possible Kamiei should share:
- the same typographic family and wordmark logic;
- the same paper-inspired material language and soft shadow treatment;
- the same core neutrals and colour relationships;
- related geometry and line weight;
- consistent icon construction, corner logic, and motion principles.

They may have distinct accent colours and distinct symbols. The distinction should be semantic and subtle, not a completely unrelated visual identity.

For Kamioto, sound may inform rhythm, continuity, and flowing line work. A future Kamiei could use framing, planes, and sequences. Do not lock either product to literal media pictograms.

## Colour direction

The previous palette is a starting point, not a final specification. Move away from a bright, saturated orange-led identity toward a warmer paper-based range:

| Token | Direction | Role |
|---|---|---|
| Washi Cream | warm ivory | primary light surface |
| Origami Sand | muted beige | secondary surface and paper layers |
| Terracotta | earthy red-orange | primary expressive accent |
| Burnt Orange | restrained warm orange | highlights and active states |
| Warm Charcoal | softened near-black | text and dark surfaces |
| Deep Ink | deep blue-charcoal | immersive dark surface |
| Paper White | neutral white | contrast and elevated surfaces |

Exact production values must be chosen after testing real UI contrast in light and dark appearances. Avoid making every screen orange or beige. The palette must support a future family member without requiring a redesign.

## Typography

Use a contemporary, highly legible sans-serif with a warm, human character. Wordmarks may use more generous tracking; interface typography should remain native-feeling and accessible.

Satoshi may be explored as a visual reference, subject to confirming its licence and bundling requirements. Inter or the iOS system font are practical interface candidates. Do not use pseudo-Japanese display fonts or decorative kanji.

## Material, lighting, and motion

- Paper texture should be subtle and tactile, never noisy or rustic.
- Prefer real-looking folds, layered edges, embossing, and soft cast shadows over glossy gradients.
- The visual system must also work as flat vector artwork and in monochrome; texture cannot carry the identity by itself.
- Motion should feel like folding, unfolding, or a surface gently changing state. Keep it brief, purposeful, and energy efficient.
- Avoid making every screen look like a sheet of stationery. The player and media artwork remain the focus.

## Logo and icon requirements

Explore the three form directions above before choosing a final mark. The final mark must:
- be abstract and ownable without the wordmark;
- remain legible at small app-icon sizes;
- work in monochrome, on light and dark backgrounds, and without texture;
- feel related to a possible future Kami family product;
- avoid literal cranes, birds, torii gates, cherry blossoms, decorative kanji, headphones, musical notes, and generic equalizer bars.

Required final assets, once a direction is approved:
- primary wordmark and horizontal lockup;
- standalone symbol;
- light, dark, and one-colour variants;
- app icon master and required platform exports;
- simplified small-size variant;
- documented clear space and minimum size.

Moodboards and generated images are exploratory references only. Rebuild approved artwork as clean vector assets and verify optical alignment and small-size legibility before shipping.

## Product expression

- Listening screens may use a deep, warm dark surface for an immersive experience.
- Library and settings screens prioritize scanability and native iOS conventions.
- Album artwork remains the visual hero; brand elements frame it rather than compete with it.
- Use paper-inspired surfaces selectively in onboarding, empty states, transitions, and brand moments.
- Support light and dark appearances, Dynamic Type, accessibility contrast, and localisation.

## Naming and technical boundaries

The customer-facing product name is **Kamioto**. Replace customer-facing “Orioto” and legacy “Mozz” branding in app display strings, marketing copy, documentation, screenshots, and release metadata as each surface is intentionally updated.

**Do not rename internal technical identifiers as part of this rebrand.** Preserve:
- Swift modules and package products such as `MozzKit`, `MozzCore`, `MozzPlayback`, and the other `Mozz*` modules;
- Rust crate names and FFI symbols;
- source directories, Xcode target names, and Objective-C runtime names unless a separate technical migration is explicitly approved;
- Bundle ID `com.thatcube.Mozz`, App Group `group.com.thatcube.Mozz`, database names, persisted keys, and on-disk paths;
- deep-link scheme `mozz://`, Bonjour service `_mozz._tcp`, Siri/Handoff identifiers, and existing service contracts.

Do not perform a blind global search-and-replace. Customer-facing strings must be distinguished from identifiers, compatibility contracts, persisted data, and upstream attribution. Keep upstream Mozz attribution and source links where legally or technically appropriate; do not present upstream distribution assets as Kamioto branding.

## Acceptance checklist

- [ ] Family-level visual grammar documented and usable by a future Kamiei without designing Kamiei prematurely.
- [ ] The Fold, Unfold, and Fold-to-Unfold explored side by side.
- [ ] Final vector logo and app icon supplied in light, dark, and monochrome variants.
- [ ] App icon tested at small sizes and against iOS appearance variants.
- [ ] Splash / launch screen uses the approved mark and palette.
- [ ] App display name is Kamioto.
- [ ] Onboarding, settings, accessibility labels, and user-visible copy use Kamioto consistently.
- [ ] README, repository description, documentation, and release copy use Kamioto.
- [ ] Upstream Mozz attribution and links are preserved where appropriate and clearly distinguished from Kamioto.
- [ ] No internal `Mozz*` module, crate, FFI, Bundle ID, App Group, deep-link, Bonjour, or persistence identifier was renamed.
- [ ] Contrast, Dynamic Type, light/dark appearance, and localisation are checked.
