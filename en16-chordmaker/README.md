# EN16 MIDI Chord Maker

Standalone USB-MIDI chord instrument for the **Intech Studio EN16** (USB-MIDI only — no CV).

After install + **Store**, play with no computer — only a MIDI host.

## Docs

| Doc | What it’s for |
|---|---|
| **[User guide](docs/USER_GUIDE.md)** | **What each encoder does** (start here to play) |
| [Installation](docs/INSTALLATION.md) | Full install (`snippets/install/` spread) |
| [Minimal install](docs/MINIMAL_INSTALL.md) | Easier 4-voice install |
| [Control map](docs/CONTROL_MAP.md) | Compact reference tables |

---

## What does what (cheat sheet)

Orientation: **USB-C = top**. Bottom-right = **enc 15**.

```text
  0   1   2   3     voices (pitch / on-off)
  4   5   6   7     voices
  8   9  10  11     transpose / octave / inversion / spread
 12  13  14  15     strum / HOLD / slot / velocity+SAVE
```

| Encoder | Turn | Push |
|---|---|---|
| **0–7** | Voice pitch (chromatic) | Voice on / off |
| **8** | Transpose | Reset transpose |
| **9** | Octave | Reset octave |
| **10** | Inversion | Reset inversion |
| **11** | Spread | Reset spread |
| **12** | Strum spacing | Toggle strum flag |
| **13** | Gate length | **Hold / release chord** |
| **14** | Select slot 1–16 | Recall that slot |
| **15** | Velocity | **Enter save / recall mode** |

### Save a chord
1. **Push 15** → save mode (slots light up; each filled slot has its own colour)  
2. **Push 14** → save arm (amber)  
3. **Push slot 0–13** (or **15** while armed → slot 16)  
4. **Push 15** again to exit (when not armed)

### Recall
- Save mode: push a coloured slot  
- Edit mode: turn **14** to choose, push **14** to load  

**Enc 14** in edit mode shows that slot’s colour so you can see which chord is selected.

### LEDs (edit)
- Voices: green = on, dim = off, blue = root  
- Enc 14: unique colour per slot  
- Enc 15: purple = unsaved edits; amber = idle  
- Enc 13 amber when hold is on  

MIDI: USB channel **1**. Chord bank is **RAM only** (clears on power cycle). Save a Grid **Profile** after install.

---

## Install (short)

Prefer: [`docs/INSTALLATION.md`](docs/INSTALLATION.md) using `snippets/install/`  
(FW ~1.5.6: ~908 chars **per element total** — don’t stack System Code Blocks.)

1. System → `system_setup.lua`  
2. Enc 0–9 Setup → `e0_setup` … `e9_setup` (each different — **no** whole-element Preset)  
3. Enc 10–15 Setup → `e_rest_setup.lua`  
4. Every enc Encoder/Button → `all_encoder.lua` / `all_button.lua`  
5. **Store** → push **13** to hear a chord  

---

## Layout

```text
en16-chordmaker/
├── snippets/install/     # paste these onto the EN16
├── docs/                 # user guide + install
├── *.lua                 # host / unit-test source
└── tests/
```

## Host tests

```bash
cd en16-chordmaker
lua tests/test_chordmaker.lua
```

## Known limitations

- Slots = session RAM (power cycle clears them); scripts persist after Store  
- Strum flag exists; timed strum not on device yet  
- Bottom-right = index 15 with default orientation  

## Inspiration

[Seque](https://github.com/mattcoffyn/Seque-MIDI-Sequencer-for-Grid) — see `docs/INSPIRATION_SEQUE.md`.
