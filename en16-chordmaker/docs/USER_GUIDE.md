# User Guide — EN16 Chord Maker

Standalone USB-MIDI chord instrument for the **Intech Studio EN16**.  
**8 voices**, hold from the encoders, **16 memory slots** — no computer after install.

Encoders are numbered **1–16** on this page (top-left = **1**, bottom-right = **16**).  
Install / Grid Editor still use element indices 0–15 — see [`INSTALLATION.md`](INSTALLATION.md).

Full tables: [`CONTROL_MAP.md`](CONTROL_MAP.md)

---

## Orientation

**USB-C edge = top.**

```text
  1   2   3   4
  5   6   7   8
  9  10  11  12
 13  14  15  16   ← bottom-right = 16
```

---

## What each encoder does

### Voices — encoders 1–8

| | Action |
|---|---|
| **Turn** | Set that voice’s pitch (MIDI 0–127, through all octaves) |
| **Push** | Enable / disable voice |

LED: **green** = on · **dim** = off · **blue** = root (encoder **1**)

### Shape — encoders 9–13

| Enc | Turn | Push |
|---|---|---|
| **9** | Transpose ± | Reset transpose |
| **10** | Octave ±3 | Reset octave |
| **11** | Inversion | Reset inversion |
| **12** | Spread | Reset spread |
| **13** | Strum spacing (ms) | Toggle strum flag |

Active param LED goes **amber**.

### Play / memory — encoders 14–16

| Enc | Turn | Push |
|---|---|---|
| **14** | Gate length (ms) | **Hold / release** the chord |
| **15** | Focus memory slot 1–16 | **Recall** focused slot |
| **16** | Velocity | **Enter save / recall mode** |

- Encoder **14** amber while hold is on  
- Encoder **15** colour = that slot’s colour (see below)  
- Encoder **16** purple = unsaved edits  

MIDI out: **USB channel 1**.

---

## First play

1. Push **14** → chord holds (Note Ons)  
2. Push **14** again → release  
3. Turn **1–8** → change pitches (re-triggers while held)  
4. Push **1–8** → mute/unmute voices  

---

## Save / recall

### Save

1. Build the chord (edit mode)  
2. **Push 16** → save mode (16 slot LEDs)  
3. **Push 15** → **Save Arm** (all amber)  
4. **Push the target slot** (**1–14**), or **push 16** while armed to save **slot 16**  
5. Slot shows its **unique colour** · arm clears  
6. Exit: **push 16** (unarmed) or **turn 16**

### Recall

| Where | How |
|---|---|
| Save mode | Push a coloured (occupied) slot (**1–16**) |
| Edit mode | Turn **15** to select · push **15** to load |

Empty slots are **dim**; pushing them does nothing useful.

### Slot colours

Each of the 16 slots has a fixed vivid colour (red, cyan, yellow, blue, …).  
Same colour appears:

- on that encoder in **save mode** when the slot is filled  
- on **encoder 15** in **edit mode** for the focused / loaded slot  

Loaded slot is **brighter**. Save-armed = **amber** on everything.

---

## Typical flows

**Hold a chord:** enable voices → tune **1–8** → optional **9–12** / **16** → push **14**.

**Bank chords:** save A to slot 1 → exit → build B → arm → slot 2 → …  
Recall with **15** or from save mode.

**Panic:** temporary System Code Block: `CM.panic()`

---

## What persists

| Data | Survives power cycle? |
|---|---|
| Grid scripts (after **Store**) | Yes |
| 16 chord slots | **No** (session RAM only) |
| Grid **Profile** backup | Yes (re-load page) |

---

## Limitations

- Timed strum not on device yet (chord sends instantly)  
- Encoder **16** = bottom-right only with default orientation  
- ~908 character budget per Grid element — use `snippets/install/`  

---

## Quick reference

| Want… | Do… |
|---|---|
| Play / stop | Push **14** |
| Change a note | Turn **1–8** |
| Mute a voice | Push **1–8** |
| Enter save mode | Push **16** |
| Arm save | Push **15** (in save mode) |
| Save to a slot | Arm, then push the slot |
| Recall | Push slot (save mode) or push **15** (edit) |
| Exit save mode | Turn **16**, or push **16** while unarmed |
| All notes off | `CM.panic()` |
