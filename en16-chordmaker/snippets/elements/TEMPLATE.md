# Per-encoder Grid Editor wiring

For **each** element `0..15`:

## Setup
```lua
self:encoder_mode(0)
self:encoder_min(0)
self:encoder_max(127)
self:button_mode(1)
if self:element_index()<=7 then self:encoder_value(cm.n[self:element_index()+1]) end
```

## Encoder (delete default MIDI CC blocks)
```lua
cm.enc(self:element_index(), self:encoder_value())
```

## Button (delete default MIDI Note blocks)
```lua
cm.btn(self:element_index(), self:button_value())
```

Optional: System → Timer (global) can stay empty in v1 (strum delay host-only for now).
