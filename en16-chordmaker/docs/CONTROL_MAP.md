# Control Map — EN16 Chord Machine

Grid **element indices 0–15** (for install / Editor).  
For play docs numbered **1–16**, see [`USER_GUIDE.md`](USER_GUIDE.md) (add 1 to each index below).

Default orientation: USB-C edge = top. Bottom-right element = **15** (user guide encoder **16**).

## Edit mode

| Enc | Rotate | Push |
|---|---|---|
| 0–7 | Voice pitch (MIDI 0–127, endless through octaves) | Toggle voice on/off |
| 8 | Transpose ± | Reset transpose |
| 9 | Octave ±3 | Reset octave |
| 10 | Inversion | Reset inversion |
| 11 | Spread | Reset spread |
| 12 | Strum spacing (ms) | Toggle strum flag |
| 13 | Gate length (ms) | **Hold / sustain chord** (play or release) |
| 14 | Select memory slot 1–16 | Recall selected slot |
| 15 | Velocity | **Enter Save/Recall mode** |

LED (edit): green = voice on, dim = off, blue = root voice, amber = active param, purple on enc15 = unsaved changes, red = muted.

## Save/Recall mode

| Action | Behaviour |
|---|---|
| Enc 0–13 push | Recall slot 1–14 if occupied; red flash if empty |
| Enc 14 push | Toggle **Save Arm** (amber LEDs) |
| Enc 15 push | If armed → save slot 16; else **exit** Save/Recall |
| Enc 15 rotate | Exit Save/Recall |
| Enc 14 rotate | Change selected slot focus |
| Armed + push slot 0–13 | Save current chord to that slot (overwrite allowed only while armed) |

LED (save): green = occupied, dim = empty, blue = loaded slot, amber = save armed.

## MIDI

- USB MIDI out, channel 1 (Grid `ch=0`)
- Note On / Off with ref-counted duplicates
- Hold mode sustains until released; panic via `CM.panic()` (add to a spare action if needed)

## Persistence

- 16 slots in **session RAM** (survive while powered / until page reload)
- Config scripts persist after Editor **Store**
- Chord bank file I/O on-device is **unverified** — export via `Storage:export_lua()` on host, or re-save slots after reboot for now
