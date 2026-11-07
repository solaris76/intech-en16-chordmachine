# Installation — Full EN16 Chord Maker

Fed up with the spread install? Use the **easy path** instead: [`MINIMAL_INSTALL.md`](MINIMAL_INSTALL.md) (4 voices, one System block, Preset OK).

After full install, see the [User Guide](USER_GUIDE.md) for play, edit, and save/recall.

> **Important (FW 1.5.6):** The ~**908 character** limit is for **all Code Blocks on one element combined**, not per block. Multiple System Setup blocks that sum over ~908 → “config limit reached”. Use the **spread install** below: **one** short System block, put the rest on encoder **Setup** events (each encoder gets its own ~908 budget).

---

## 0. Clear the page first

1. Strip factory **MIDI CC** / **MIDI Note** from encoders (blank Preset on enc 0 → apply to 1–15), or use an unused page  
2. Confirm you have free config memory (tens of k is fine)  
3. System (element 16) → Setup should be empty  
4. **Store**

---

## 1. System Setup — **one** Code Block only

**On the same page you’re installing** (e.g. page 2): **System (16) → Setup** → single Code Block → paste:

`snippets/install/system_setup.lua`

Do **not** add a second System Code Block.

Must start with `CM={ch=0`. After Store, Debug monitor should show `CM` once on page load. If you never see that, System Setup isn’t on this page and nothing else will work.

---

## 2. Encoder Setup — library spread (elements 0–9)

Each file is **one** Code Block on that encoder’s **Setup** event (replace other Setup actions if needed):

| Element | Paste |
|---|---|
| 0 | `snippets/install/e0_setup.lua` |
| 1 | `snippets/install/e1_setup.lua` |
| 2 | `snippets/install/e2_setup.lua` |
| 3 | `snippets/install/e3_setup.lua` |
| 4 | `snippets/install/e4_setup.lua` |
| 5 | `snippets/install/e5_setup.lua` |
| 6 | `snippets/install/e6_setup.lua` |
| 7 | `snippets/install/e7_setup.lua` |
| 8 | `snippets/install/e8_setup.lua` |
| 9 | `snippets/install/e9_setup.lua` |

Init order is System → 0 → 1 → … so paste in that order.

**After each paste, check the first line before moving on:**

| El | First line must be |
|---|---|
| Sys | `CM={ch=0` |
| 0 | `function CM.on` |
| 1 | `function CM.comp` |
| 2 | `function CM.trig` |
| 3 | `function CM.apply` |
| 4 | `function CM.col` |
| 5 | `function CM.p` |
| 6 | `function CM.dlt` |
| 7 | `function CM._ed` |
| 8 | `function CM.btn` |
| 9 | `function CM._b2` |

If several elements all show `function CM.on`, Grid cloned enc 0 (Preset) or failed to overwrite. Use the rebuild below — **never** apply a whole-element Preset after this step.

### Rebuild when Editor keeps showing the wrong Setup

For **each** element 0–9 (one at a time):

1. Setup → **delete** the Code Block action (trash the action)  
2. **Store**  
3. **+** new Code Block  
4. Paste the matching `eN_setup.lua`  
5. Confirm first line matches the table  
6. **Store**  
7. Click another element, click back — still correct? Only then do the next index  

Do **not** batch with Presets.

---

## 3. Encoders 10–15 Setup

On each of **10–15** → Setup → paste:

`snippets/install/e_rest_setup.lua`

(Or copy element 10’s Setup Preset to 11–15.)

---

## 4. Encoder + Button events (all 16)

> **Do not** save a whole-element Preset from enc 0 and apply to 1–15 after step 2 — that **overwrites** each encoder’s unique Setup library and leaves you with blank LEDs / no MIDI.

On **every** encoder `0..15`, edit **Encoder** and **Button** only:

| Event | File | Also |
|---|---|---|
| Encoder | `snippets/install/all_encoder.lua` | Delete factory MIDI CC |
| Button | `snippets/install/all_button.lua` | Delete factory MIDI Note |

Paste those two events on each element (or use a Preset **only if** it does not replace Setup — when in doubt, paste by hand). **Leave Setup alone** after step 2–3.

---

## 5. Store & smoke test

1. **Store**  
2. Quit Editor; plug into a MIDI host  
3. Push **encoder 13** → chord holds  
4. Turn **0–7** → pitches move  
5. Push **15** → Save/Recall; **14** → Save Arm  

---

## 6. Backup

Save the page as a **Profile** so you never re-paste.

---

## Panic

Temporary Code Block: `CM.panic()`

---

## Legacy (10 System blocks)

The old `snippets/device/*` “10 System Code Blocks” layout **does not work** when the ~908 limit is per-element total. Use `snippets/install/` instead.
