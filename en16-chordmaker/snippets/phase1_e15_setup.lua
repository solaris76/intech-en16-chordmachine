-- Paste into: Element 15 (bottom-right) → Setup → Code Block
-- Clears default CC MIDI; maps absolute 0..127 to note; button as toggle.

self:encoder_mode(0)
self:encoder_min(0)
self:encoder_max(127)
self:encoder_value(cm_note)
self:button_mode(1)
cm_paint()
