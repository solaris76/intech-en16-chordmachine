# Minimal install — 4 voices (easier)

Smaller feature set so every encoder can share the **same** Setup (**Preset OK**).

## What you get
- Voices on encoders **1–4** (turn = pitch, push = on/off)  
- Encoder **14** push = hold / release  
- Basic green LEDs  
- No save/recall, transpose, etc.

Full app: [`INSTALLATION.md`](INSTALLATION.md) · Play docs: [`USER_GUIDE.md`](USER_GUIDE.md) (1–16 numbering)

## Steps

### 1. System (element 16) → Setup
One Code Block → paste `snippets/install/minimal_system.lua`

### 2. Element 0 (user encoder 1), then Preset
| Event | Paste |
|---|---|
| Setup | `minimal_enc_setup.lua` |
| Encoder | `all_encoder.lua` |
| Button | `all_button.lua` |

Delete factory MIDI CC / Note.  
Save as Preset → apply to elements **1–15**.

### 3. Store
Push **14** = hold; turn **1–4** = pitches.
