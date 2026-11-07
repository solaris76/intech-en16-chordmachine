-- Isolates Grid hardware calls so musical logic can be tested on a normal Lua host.
-- On device, these functions resolve to real Grid APIs (see docs/API_VERIFICATION.md).
-- Off device, inject mocks via GridAdapter.use(mocks).

local GridAdapter = {
  _midi = nil,
  _led = nil,
  _timer = nil,
}

function GridAdapter.use(mocks)
  mocks = mocks or {}
  GridAdapter._midi = mocks.midi_send
  GridAdapter._led = mocks.led
  GridAdapter._timer = mocks.timer
end

local function real_or(name, fallback)
  local g = rawget(_G, name)
  if type(g) == "function" then
    return g
  end
  return fallback
end

function GridAdapter.midi_send(channel, command, p1, p2)
  local fn = GridAdapter._midi or real_or("midi_send", nil)
  if not fn then
    error("midi_send unavailable (not on Grid and no mock installed)")
  end
  return fn(channel, command, p1, p2)
end

function GridAdapter.note_on(channel, note, velocity)
  return GridAdapter.midi_send(channel, 144, note, velocity)
end

function GridAdapter.note_off(channel, note, velocity)
  velocity = velocity or 0
  return GridAdapter.midi_send(channel, 128, note, velocity)
end

-- Confirmed common form: led_color(led, layer, r, g, b)
function GridAdapter.led_color(led, layer, r, g, b)
  if GridAdapter._led and GridAdapter._led.color then
    return GridAdapter._led.color(led, layer, r, g, b)
  end
  local fn = real_or("led_color", nil)
  if fn then
    return fn(led, layer, r, g, b)
  end
  error("led_color unavailable (not on Grid and no mock installed)")
end

function GridAdapter.led_value(led, layer, intensity)
  if GridAdapter._led and GridAdapter._led.value then
    return GridAdapter._led.value(led, layer, intensity)
  end
  local fn = real_or("led_value", nil)
  if fn then
    return fn(led, layer, intensity)
  end
  error("led_value unavailable (not on Grid and no mock installed)")
end

function GridAdapter.led_address(element_index, n)
  n = n or 0
  local fn = real_or("led_address_get", nil)
  if fn then
    local addr = fn(element_index, n)
    if addr ~= nil then
      return addr
    end
  end
  -- Fallback used on older FW / host tests: assume 1:1 mapping.
  return element_index
end

function GridAdapter.timer_start(element_index, ms)
  if GridAdapter._timer and GridAdapter._timer.start then
    return GridAdapter._timer.start(element_index, ms)
  end
  local fn = real_or("timer_start", nil)
  if fn then
    return fn(element_index, ms)
  end
  error("timer_start unavailable")
end

function GridAdapter.timer_stop(element_index)
  if GridAdapter._timer and GridAdapter._timer.stop then
    return GridAdapter._timer.stop(element_index)
  end
  local fn = real_or("timer_stop", nil)
  if fn then
    return fn(element_index)
  end
  error("timer_stop unavailable")
end

return GridAdapter
