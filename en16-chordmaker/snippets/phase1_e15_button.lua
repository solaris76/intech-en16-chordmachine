-- Paste into: Element 15 → Button event → Code Block ONLY
-- Remove default Note MIDI blocks from this event.
-- Toggle sustain: press ON = Note On held; press OFF = Note Off.
-- EN16 alone sends USB MIDI — no computer needed after Store.

if self:button_value() ~= 0 then
  if cm_sus == 0 then
    cm_sus = 1
    cm_note_on()
  else
    cm_sus = 0
    cm_note_off()
  end
  cm_paint()
end
