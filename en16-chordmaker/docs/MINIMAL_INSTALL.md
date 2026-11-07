# Minimal Chord Maker — easy install

Smaller feature set so you **don’t** fight the 16-way Setup spread.  
**Preset-friendly:** every encoder gets the **same** Setup.

## What you get
- 4 voices (enc 0–3 turn = pitch, push = on/off)
- Enc **13** push = hold / release chord
- Basic green LEDs on voices
- No save/recall, transpose, strum, etc.

## Install (page of your choice)

### 1. System (16) → Setup
One Code Block only — paste `snippets/install/minimal_system.lua` (~902 chars).

### 2. One encoder, then Preset to all
On **element 0**:

| Event | Paste |
|---|---|
| Setup | `snippets/install/minimal_enc_setup.lua` |
| Encoder | `snippets/install/all_encoder.lua` |
| Button | `snippets/install/all_button.lua` |

Delete factory MIDI CC / Note.

Save element 0 as a **Preset** → apply to **1–15**. Same Setup on all is OK here.

### 3. Store
Push **13** = hold; turn **0–3** = pitches.

## vs full install
Full app (`docs/INSTALLATION.md` + `e0`…`e9` spread) has 8 voices + memory slots, but Grid’s ~908 **per-element** limit makes Setup pastes painful. Use minimal until you want the full feature set (or File Manager `require()`).
