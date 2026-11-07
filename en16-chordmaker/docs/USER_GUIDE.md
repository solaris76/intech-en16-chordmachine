# User Guide — EN16 Chord Maker

Standalone USB-MIDI chord instrument for the **Intech Studio EN16**.  
**8 voices**, hold from the encoders, **16 memory slots** — no computer after install.

Install: [`INSTALLATION.md`](INSTALLATION.md) · Full tables: [`CONTROL_MAP.md`](CONTROL_MAP.md)

---

## Orientation

**USB-C edge = top.** Indices:

```text
  0   1   2   3
  4   5   6   7
  8   9  10  11
 12  13  14  15   ← bottom-right = 15
```

---

## What each encoder does

### Voices — enc 0–7

| | Action |
|---|---|
| **Turn** | Set that voice’s pitch (MIDI 0–127, through all octaves) |
| **Push** | Enable / disable voice |

LED: **green** = on · **dim** = off · **blue** = root (voice 0)

### Shape — enc 8–12

| Enc | Turn | Push |
|---|---|---|
| **8** | Transpose ± | Reset transpose |
| **9** | Octave ±3 | Reset octave |
| **10** | Inversion | Reset inversion |
| **11** | Spread | Reset spread |
| **12** | Strum spacing (ms) | Toggle strum flag |

Active param LED goes **amber**.

### Play / memory — enc 13–15

| Enc | Turn | Push |
|---|---|---|
| **13** | Gate length (ms) | **Hold / release** the chord |
| **14** | Focus memory slot 1–16 | **Recall** focused slot |
| **15** | Velocity | **Enter save / recall mode** |

- Enc **13** amber while hold is on  
- Enc **14** colour = that slot’s colour (see below)  
- Enc **15** purple = unsaved edits  

MIDI out: **USB channel 1**.

---

## First play

1. Push **13** → chord holds (Note Ons)  
2. Push **13** again → release  
3. Turn **0–7** → change pitches (re-triggers while held)  
4. Push **0–7** → mute/unmute voices  

---

## Save / recall

### Save

1. Build the chord (edit mode)  
2. **Push 15** → save mode (16 slot LEDs)  
3. **Push 14** → **Save Arm** (all amber)  
4. **Push the target slot** (**0–13**), or **push 15** while armed to save **slot 16**  
5. Slot shows its **unique colour** · arm clears  
6. Exit: **push 15** (unarmed) or **turn 15**

### Recall

| Where | How |
|---|---|
| Save mode | Push a coloured (occupied) slot |
| Edit mode | Turn **14** to select · push **14** to load |

Empty slots are **dim**; pushing them does nothing useful.

### Slot colours

Each of the 16 slots has a fixed vivid colour (red, cyan, yellow, blue, …).  
Same colour appears:

- on that encoder in **save mode** when the slot is filled  
- on **enc 14** in **edit mode** for the focused / loaded slot  

Loaded slot is **brighter**. Save-armed = **amber** on everything.

---

## Typical flows

**Hold a chord:** enable voices → tune 0–7 → optional 8–11 / 15 → push **13**.

**Bank chords:** save A to slot 0 → exit → build B → arm → slot 1 → …  
Recall with **14** or from save mode.

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
- Index 15 = bottom-right only with default orientation  
- ~908 character budget per Grid element — use `snippets/install/`  

---

## Quick reference

| Want… | Do… |
|---|---|
| Play / stop | Push **13** |
| Change a note | Turn **0–7** |
| Mute a voice | Push **0–7** |
| Enter save mode | Push **15** |
| Arm save | Push **14** (in save mode) |
| Save to a slot | Arm, then push the slot |
| Recall | Push slot (save mode) or push **14** (edit) |
| Exit save mode | Turn **15**, or push **15** while unarmed |
| All notes off | `CM.panic()` |
