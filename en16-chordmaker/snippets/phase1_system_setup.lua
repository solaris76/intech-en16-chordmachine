-- Paste into: System Events → Setup (Init) → Code Block
-- Shared Phase 1 state for the bottom-right encoder proof.

cm_ch = 0
cm_vel = 100
cm_note = 60
cm_sus = 0
cm_el = 15

function cm_paint()
  local led = cm_el
  if led_address_get then
    local a = led_address_get(cm_el, 0)
    if a ~= nil then led = a end
  end
  if cm_sus == 1 then
    led_color(led, 1, 0, 255, 0)
    led_value(led, 1, 127)
  else
    led_color(led, 1, 40, 40, 40)
    led_value(led, 1, 40)
  end
end

function cm_note_on()
  midi_send(cm_ch, 144, cm_note, cm_vel)
end

function cm_note_off()
  midi_send(cm_ch, 128, cm_note, 0)
end

function cm_set_note(n)
  if n < 0 then n = 0 end
  if n > 127 then n = 127 end
  n = n // 1
  if n == cm_note then return end
  local old = cm_note
  if cm_sus == 1 then
    midi_send(cm_ch, 128, old, 0)
    cm_note = n
    midi_send(cm_ch, 144, cm_note, cm_vel)
  else
    cm_note = n
  end
end

cm_paint()
