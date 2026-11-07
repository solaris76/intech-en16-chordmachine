local M = {}

function M.new()
  local adapter = { log = {} }
  adapter.midi_send = function(ch, cmd, p1, p2)
    adapter.log[#adapter.log + 1] = { "midi", ch, cmd, p1, p2 }
  end
  adapter.note_on = function(ch, note, vel)
    adapter.log[#adapter.log + 1] = { "midi", ch, 144, note, vel }
  end
  adapter.note_off = function(ch, note, vel)
    adapter.log[#adapter.log + 1] = { "midi", ch, 128, note, vel or 0 }
  end
  adapter.led_color = function(led, layer, r, g, b)
    adapter.log[#adapter.log + 1] = { "led_color", led, layer, r, g, b }
  end
  adapter.led_value = function(led, layer, intensity)
    adapter.log[#adapter.log + 1] = { "led_value", led, layer, intensity }
  end
  adapter.led_address = function(element_index, n)
    return element_index
  end
  return adapter
end

function M.find_midi(log, cmd, note)
  local hits = {}
  for _, e in ipairs(log) do
    if e[1] == "midi" and e[3] == cmd and (note == nil or e[4] == note) then
      hits[#hits + 1] = e
    end
  end
  return hits
end

return M
