-- Paste into: Element 15 → Encoder event → Code Block ONLY
-- Remove default MIDI CC action blocks from this event.
-- Endless scroll: each step moves chromatically; 0..127 spans all octaves.

cm_set_note(self:encoder_value())
cm_paint()
