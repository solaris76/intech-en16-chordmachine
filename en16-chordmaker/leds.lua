-- LED state with priority (higher wins). Avoids redundant hardware writes.

local Leds = {}
Leds.__index = Leds

-- priority: warn(100) > save_arm(80) > loaded(60) > dirty/mute(50) > base(10)
local PRI = {
  base = 10,
  dirty = 50,
  mute = 55,
  loaded = 60,
  save_arm = 80,
  flash = 90,
  warn = 100,
}

function Leds.new(adapter, config)
  local self = setmetatable({}, Leds)
  self.adapter = adapter
  self.cfg = config
  self.state = {} -- [el] = {r,g,b,inten,pri,tag}
  self.flashing = {} -- [el] = {until_ms, r,g,b, inten}
  self.now_ms = function() return 0 end
  return self
end

function Leds:set_clock(fn)
  self.now_ms = fn
end

function Leds:led_index(el)
  return self.adapter.led_address(el, 0)
end

function Leds:_apply(el, r, g, b, inten)
  local led = self:led_index(el)
  local layer = self.cfg.led_layer_button
  self.adapter.led_color(led, layer, r, g, b)
  self.adapter.led_value(led, layer, inten)
end

function Leds:set(el, r, g, b, inten, pri, tag)
  pri = pri or PRI.base
  local cur = self.state[el]
  if cur and cur.pri > pri then
    return
  end
  if cur and cur.r == r and cur.g == g and cur.b == b and cur.inten == inten and not self.flashing[el] then
    cur.pri = pri
    cur.tag = tag
    return
  end
  self.state[el] = { r = r, g = g, b = b, inten = inten, pri = pri, tag = tag }
  if not self.flashing[el] then
    self:_apply(el, r, g, b, inten)
  end
end

function Leds:clear_priority(el)
  local cur = self.state[el]
  if cur then cur.pri = PRI.base end
end

function Leds:flash(el, r, g, b, inten, ms)
  self.flashing[el] = {
    until_ms = self.now_ms() + ms,
    r = r, g = g, b = b, inten = inten,
  }
  self:_apply(el, r, g, b, inten)
end

function Leds:tick()
  local now = self.now_ms()
  for el, f in pairs(self.flashing) do
    if now >= f.until_ms then
      self.flashing[el] = nil
      local cur = self.state[el]
      if cur then
        self:_apply(el, cur.r, cur.g, cur.b, cur.inten)
      end
    end
  end
end

function Leds:color_named(name)
  return self.cfg.colors[name]
end

Leds.PRI = PRI

return Leds
