# Grid Editor event map

## System → Setup (order matters)

1. `snippets/device/01_state.lua`
2. `snippets/device/02_midi.lua`
3. `snippets/device/03_chord_a.lua`
4. `snippets/device/04_chord_b.lua`
5. `snippets/device/05_apply_bank.lua`
6. `snippets/device/06_leds.lua`
7. `snippets/device/07_leds_b.lua`
8. `snippets/device/08_enc_a.lua`
9. `snippets/device/08_enc_b.lua`
10. `snippets/device/09_btn.lua` (calls `cm.paint()` at end)

## Every element 0–15

| Event | Snippet |
|---|---|
| Setup | `snippets/elements/all_setup.lua` |
| Encoder | `snippets/elements/all_encoder.lua` → `cm.enc(i,v)` |
| Button | `snippets/elements/all_button.lua` → `cm.btn(i,v)` |

Remove factory MIDI blocks on Encoder and Button events.
