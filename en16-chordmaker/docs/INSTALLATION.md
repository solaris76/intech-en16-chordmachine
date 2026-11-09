# Installation — EN16 Chord Machine (full)

Paste the scripts in `snippets/install/` into Grid Editor, then **Store**.  
After that, play from the [User Guide](USER_GUIDE.md) (encoders numbered **1–16**).

Want an easier 4-voice install? → [`MINIMAL_INSTALL.md`](MINIMAL_INSTALL.md)

---

## Before you start

| Need | Notes |
|---|---|
| EN16 | Firmware **1.5.6+** recommended |
| Grid Editor | Connected to the module |
| Free page | Prefer an empty page (e.g. page 2) so factory MIDI isn’t in the way |
| Free config memory | Tens of k free is enough |

**Why so many pastes?** Grid allows ~**908 characters per element**. The app is larger than that, so code is split: **one** System block + unique **Setup** on encoders 1–10 (elements 0–9).

**Critical:** Do **not** copy a whole-element Preset from encoder 1 onto the others after the Setup spread — that clones the wrong Setup and breaks the app.

In Grid Editor, elements are **0–15** (System = **16**). That matches the file names (`e0`…`e9`). User guide numbers are those **+ 1**.

---

## Checklist (do in order)

### 1. Clear the page
1. Remove factory **MIDI CC** / **MIDI Note** from encoders (or use a blank page).  
2. System (16) → Setup should be empty.  
3. **Store**.

### 2. System Setup — one block only
1. Select **System (element 16)** → **Setup**.  
2. Add **one** Code Block.  
3. Paste all of: `snippets/install/system_setup.lua`  
4. First line must be: `CM={ch=0`  
5. Do **not** add a second System Code Block.  
6. **Store**. Debug should print `CM` once on page load.

### 3. Encoder Setup — unique files (elements 0–9)

On each encoder’s **Setup** event, **one** Code Block, paste the matching file:

| Grid element | User guide enc | File | First line must be |
|---|---|---|---|
| 0 | 1 | `e0_setup.lua` | `function CM.on` |
| 1 | 2 | `e1_setup.lua` | `function CM.comp` |
| 2 | 3 | `e2_setup.lua` | `function CM.trig` |
| 3 | 4 | `e3_setup.lua` | `function CM.apply` |
| 4 | 5 | `e4_setup.lua` | `function CM.sc` or `function CM.col` |
| 5 | 6 | `e5_setup.lua` | `function CM.p` |
| 6 | 7 | `e6_setup.lua` | `function CM.dlt` |
| 7 | 8 | `e7_setup.lua` | `function CM._ed` |
| 8 | 9 | `e8_setup.lua` | `function CM.btn` |
| 9 | 10 | `e9_setup.lua` | `function CM._b2` |

**How to paste so Grid doesn’t revert**

For each element 0→9:

1. Trash any existing Setup Code Block → **Store**  
2. Add a **new** Code Block → paste file → check first line  
3. **Store** → click away → click back → still correct?  
4. Only then do the next element  

If several Setups all start with `function CM.on`, a Preset cloned encoder 0 — redo those elements with the table above.

### 4. Encoder Setup — elements 10–15 (user enc 11–16)

Paste the **same** file on each Setup:

`snippets/install/e_rest_setup.lua`

Preset from element 10 → 11–15 is OK here (identical Setup).

### 5. Encoder + Button events (all 16)

On **every** element 0–15, **Encoder** and **Button** only (leave Setup alone):

| Event | Paste | Remove |
|---|---|---|
| Encoder | `all_encoder.lua` | Factory MIDI CC |
| Button | `all_button.lua` | Factory MIDI Note |

Paste by hand, or use a Preset **only if** it does not overwrite Setup.

### 6. Store and test

1. **Store**  
2. LEDs should light (voices green, etc.)  
3. Push user-guide **encoder 14** (Grid element **13**) → chord Note Ons  
4. Turn encoders **1–8** → pitches change  
5. Push **16** → save mode; **15** → save arm; save a slot  

If you only get a single top note (e.g. G8 @ 127), factory MIDI Note is still on a Button event — delete it.

### 7. Backup
Save the page as a **Profile** so you never re-paste.

---

## Smoke-test failures

| Symptom | Likely cause |
|---|---|
| No LEDs, `CM.enc` / `CM.btn` nil in Debug | Setup spread overwritten / incomplete; check first-line table |
| `config limit reached` on System | Second System Code Block — keep **one** only |
| Setup keeps reverting to `CM.on` | Editor didn’t replace block — trash → Store → new block → paste |
| Double-press needed | `button_mode` must be **0** (momentary) — already in current snippets |
| Chord bank empty after reboot | Expected — slots are session RAM; scripts persist after Store |

Panic (stuck notes): temporary System Code Block → `CM.panic()`

---

## File map

All under `snippets/install/`:

```text
system_setup.lua      → System Setup (once)
e0_setup.lua … e9_setup.lua → elements 0–9 Setup (unique)
e_rest_setup.lua      → elements 10–15 Setup
all_encoder.lua       → every Encoder event
all_button.lua        → every Button event
```

Legacy `snippets/device/*` (many System blocks) — **do not use** on FW with a ~908 per-element budget.
