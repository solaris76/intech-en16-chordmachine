# Grid API Verification (Phase 1)

Research date: 2026-11-06  
Target hardware: Intech Studio EN16 (USB MIDI only — no NTX-8CV / CV path)  
Primary docs: https://docs.intech.studio/

**Rule used:** only APIs confirmed below are called from adapters. Anything else is marked unverified and must not be invented.

---

## Confirmed APIs

### MIDI output

| API | Signature | Source | Notes |
|---|---|---|---|
| `midi_send` | `midi_send(channel, command, parameter1, parameter2)` | [MIDI action](https://docs.intech.studio/wiki/actions/midi/midi/) | Shortname `gms`. Channel **0–15** (= DAW ch 1–16). |

Confirmed command values from the same page:

| Command | Meaning |
|---|---|
| `144` | Note On |
| `128` | Note Off |
| `176` | Control Change |
| `192` | Program Change |

Parameter meanings:

- Note On/Off: `parameter1` = note (0–127), `parameter2` = velocity (0–127)
- CC: `parameter1` = CC number, `parameter2` = value

**Standalone behaviour (confirmed by product model + docs):** after a configuration is **Stored** on the module, the EN16 sends USB MIDI by itself. Grid Editor is only required for editing/configuring, not for performance.

### LED

| API | Signature / usage | Source | Notes |
|---|---|---|---|
| `led_color` | `led_color(led, layer, r, g, b)` (sometimes with extra intensity arg in community snippets) | [Color](https://docs.intech.studio/wiki/actions/led/led-color/), forum examples | Layers: **1** = button/pot, **2** = encoder/endless |
| `led_value` | `led_value(led, layer, intensity)` | Forum / Intensity block references | Intensity often 0–127 |
| `led_address_get` | `led_address_get(element, n)` | Forum (FW ≥ 1.4.0) | Prefer this over assuming LED index == element index |
| `led_default_red/green/blue` | no-arg helpers | Color docs | Page default colours |

**UNVERIFIED exact arity** of older `led_color(..., intensity_flag)` variants across firmware versions. Phase 1 adapter tries the common 5-arg form first; hardware check required.

### Element methods (EN16 encoder + push)

Confirmed via Intech forum EN16 snippets and docs:

| Method | Usage |
|---|---|
| `self:element_index()` | Control element index 0–15 |
| `self:encoder_value()` / `self:encoder_value(v)` | Get/set absolute encoder value |
| `self:button_value()` | Button value (commonly 0 or 127) |
| `self:encoder_mode(m)` | Absolute/relative mode |
| `self:encoder_min(v)` / `self:encoder_max(v)` | Limits |
| `self:encoder_velocity(v)` | Encoder acceleration/sensitivity |
| `self:button_mode(m)` | Momentary vs toggle steps |

### Timers (needed later for strum/gate; not required for Phase 1 sustain toggle)

| API | Signature | Source |
|---|---|---|
| `timer_start` | `timer_start(element_index, ms)` | [Timer Start](https://docs.intech.studio/wiki/actions/timer/timer-start/) |
| `timer_stop` | `timer_stop(element_index)` | [Timer Stop](https://docs.intech.studio/wiki/actions/timer/timer-stop/) |

Index one past the last UI element starts/stops the **global** timer (EN16: index `16`).

### Events (Grid Editor)

| Event | When it runs |
|---|---|
| Setup (Init) | Once at page/module start |
| Encoder | Encoder rotation |
| Button | Encoder push press/release (or toggle steps) |
| Timer | After `timer_start` expires |
| System MIDI RX | Incoming MIDI (optional) |

### Persistence of *configuration*

| Action | Meaning | Source |
|---|---|---|
| Live edit in Editor | Sent immediately to hardware for testing | JP Editor guide / forum |
| **Store** | Writes config into module NVRAM so it survives unplug/reboot | JP Editor guide, forum |

There is no separate documented “Commit” step distinct from Store in current Editor UX. Prompt “Commit and Store” maps to: validate live → **Store**.

---

## Unverified / blocked for Phase 1+

| Topic | Status | Impact |
|---|---|---|
| Runtime `io.open` / LittleFS file write from Lua | Mentioned in grid-fw release notes (Lua I/O access) but **not** documented as a stable public chord-bank API | Do **not** claim NV chord banks until tested on device FW version |
| `require` / multi-file Lua modules on device | Open FW issue / experimental FS; classic Grid workflow uses Code Blocks + System globals | Phase 1 uses pasted snippets + shared System Setup globals |
| `os.clock`, `loadfile` | Not confirmed for Grid runtime | Avoid |
| Long-press detection reliability | Possible via `timer_start` on Button press + cancel on release, but not a first-class API | Prefer Save Arm later if flaky |
| Exact EN16 element index of “bottom-right” after module rotation | Orientation-dependent | Verify once; default assumption documented below |
| Character limit | Forum ~899/block since FW v1.5.0; on **FW 1.5.6 ~908 total per element** (all Code Blocks on that element summed) | Never stack big System Setup blocks; use `snippets/install/` spread |
| `midi_send` burst rate | Community: ~14–16 sends in one event can drop; space with timers | Important for 8-voice chord on/off |
| Profile Cloud distribution | Seque ships via `grid-editor://?config-link=...` | Preferred install path later vs multi-file require |

See also `docs/INSPIRATION_SEQUE.md`.

---

## Phase 1 hardware assumptions

1. **Bottom-right encoder** = element index **15** when the EN16 USB-C edge is oriented as Intech’s default “top”.
2. Rotation of that encoder changes a single MIDI note pitch (chromatic, absolute 0–127 mapped as note number).
3. Push of that encoder **toggles sustain**: first press → Note On (held); second press → Note Off.
4. USB MIDI leaves the EN16 alone — no computer required after Store, only a USB MIDI host (synth, interface, phone, etc.).

If bottom-right is not index 15 on your physical orientation, report the index shown by `print(self:element_index())` in a Button Code Block.

---

## Outstanding questions for the user / hardware session

1. Exact firmware version on the EN16 (`v1.x.y`)?
2. Does bottom-right report `element_index() == 15`?
3. Preferred MIDI channel for Phase 1 (default **0** = channel 1)?
4. Confirm Note On appears in a MIDI monitor when the EN16 is plugged into a host **without** Grid Editor running.
5. Preferred LED colour for sustain-on vs sustain-off?
