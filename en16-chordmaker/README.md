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

User numbering: **1–16** (top-left = **1**, bottom-right = **16**). USB-C = top.

```text
  1   2   3   4     voices (pitch / on-off)
  5   6   7   8     voices
  9  10  11  12     transpose / octave / inversion / spread
 13  14  15  16     strum / HOLD / slot / velocity+SAVE
```

| Encoder | Turn | Push |
|---|---|---|
| **1–8** | Voice pitch (chromatic) | Voice on / off |
| **9** | Transpose | Reset transpose |
| **10** | Octave | Reset octave |
| **11** | Inversion | Reset inversion |
| **12** | Spread | Reset spread |
| **13** | Strum spacing | Toggle strum flag |
| **14** | Gate length | **Hold / release chord** |
| **15** | Select slot 1–16 | Recall that slot |
| **16** | Velocity | **Enter save / recall mode** |

### Save a chord
1. **Push 16** → save mode (slots light up; each filled slot has its own colour)  
2. **Push 15** → save arm (amber)  
3. **Push slot 1–14** (or **16** while armed → slot 16)  
4. **Push 16** again to exit (when not armed)

### Recall
- Save mode: push a coloured slot  
- Edit mode: turn **15** to choose, push **15** to load  

**Encoder 15** in edit mode shows that slot’s colour so you can see which chord is selected.

### LEDs (edit)
- Voices: green = on, dim = off, blue = root (encoder 1)  
- Encoder 15: unique colour per slot  
- Encoder 16: purple = unsaved edits; amber = idle  
- Encoder 14 amber when hold is on  

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
