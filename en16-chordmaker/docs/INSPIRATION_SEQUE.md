# Inspiration notes — Seque (EN16)

Source: https://github.com/mattcoffyn/Seque-MIDI-Sequencer-for-Grid  
Profile Cloud: `grid-editor://?config-link=V67kSzIxCPu7xmDfVS1g`  
Repo ships README only (no Lua sources); real config lives in Profile Cloud.

Seque is an **8-channel polyphonic sequencer**, not a chord memory instrument. Useful patterns for our EN16 chord maker:

## What to borrow

| Seque idea | Chord-maker use |
|---|---|
| Encoders **0–7** = eight independent voices / steps | Aligns with our Edit Mode voices 1–8 |
| Encoder **button toggles enable** without destroying pitch | Same as voice enable/disable |
| Encoders **8–11** pitch for upper voices via **push+rotate** | Densifies pitch editing when 16 knobs are scarce |
| Encoder **12** scale/mode + apply on push | Optional Phase 4 scale quantise UX |
| Encoder **13** root select; push **applies** transpose; LED bright = pending | “Pending vs applied” LED pattern for transpose / save-arm |
| Encoder **15** (bottom-right) = **global start/stop toggle** | Confirms bottom-right as a primary transport/sustain control — matches our Phase 1 sustain toggle |
| LED colour families (on/off/pending/flash on event) | Same LED-as-UI philosophy |
| Ship as **Grid Profile Cloud** link, not loose multi-file `require` | Real distribution path for EN16 |
| Intech reworked Seque for **profile size / older modules** | Keep Code Blocks short; share globals from System Setup |

## What not to copy blindly

- Global timer + per-voice counters = sequencer timing, not held chords
- Random rhythm generator — out of scope for v1 chord memory
- Their full layout conflicts with our Save/Recall on 16 slots (Phase 3)

## Runtime lessons reinforced elsewhere / by Seque’s stack

1. **`midi_send` is the real note API** (not invented helpers).
2. **Timers** (`timer_start` / element or global Timer events) are the supported non-blocking delay path — use later for strum/gate.
3. Community reports a practical burst limit around **~14–16 `midi_send`s in one event**; for 8-voice chords prefer short spacing via timer if hosts drop notes.
4. Element indices in Seque docs are **0–15** (bottom-right = **15**) — same assumption as Phase 1.

## Phase 1 takeaway

Our Phase 1 (element 15 push = sustain, rotate = pitch across octaves) is consistent with Seque’s “bottom-right = global play control” convention. No change required to the Phase 1 snippets.
