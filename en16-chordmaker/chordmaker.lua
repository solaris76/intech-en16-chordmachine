-- EN16 Chord Machine application root (host-testable).

local Config = require("config")
local GridAdapter = require("grid_adapter")
local Midi = require("midi")
local Scheduler = require("scheduler")
local Chords = require("chords")
local Storage = require("storage")
local Leds = require("leds")
local Controls = require("controls")

local App = {}
App.__index = App

function App.new(opts)
  opts = opts or {}
  local self = setmetatable({}, App)
  self.cfg = opts.config or Config
  self.adapter = opts.adapter or GridAdapter
  self.clock_ms = opts.clock_ms or function() return 0 end

  self.midi = Midi.new(self.adapter, {
    channel = self.cfg.midi_channel,
    velocity = self.cfg.velocity,
  })
  self.scheduler = Scheduler.new({
    now_ms = function() return self.clock_ms() end,
    on_arm_timer = opts.on_arm_timer,
  })
  self.chord = Chords.new({
    config = self.cfg,
    midi = self.midi,
    scheduler = self.scheduler,
  })
  self.storage = Storage.new({
    slots = self.cfg.slots,
    version = self.cfg.bank_version,
    file_io = opts.file_io,
  })
  self.leds = Leds.new(self.adapter, self.cfg)
  self.leds:set_clock(function() return self.clock_ms() end)
  self.controls = Controls.new(self)
  self.loaded_slot = nil
  return self
end

function App:mark_clean()
  self.controls.dirty = false
end

function App:save_slot(slot)
  local ok = self.storage:save(slot, self.chord:snapshot())
  if ok then
    self.loaded_slot = slot
    self:mark_clean()
    local el = slot - 1
    self.leds:flash(el, 0, 255, 80, 127, 250)
  else
    self.leds:flash(slot - 1, 255, 0, 0, 127, 250)
  end
  return ok
end

function App:recall_slot(slot)
  local snap = self.storage:get(slot)
  if not snap then
    self.leds:flash(slot - 1, 255, 0, 0, 127, 200)
    return false
  end
  self.chord:transition_to_snapshot(snap)
  self.loaded_slot = slot
  self.controls.selected_slot = slot
  self:mark_clean()
  return true
end

function App:delete_slot(slot)
  return self.storage:delete(slot)
end

function App:panic()
  self.chord:release()
  self.midi:panic()
  self:refresh_leds()
end

function App:trigger()
  self.chord:trigger()
  self:refresh_leds()
end

function App:release()
  self.chord:release()
  self:refresh_leds()
end

function App:refresh_leds()
  local c = self.cfg.colors
  local ctrl = self.controls
  local ch = self.chord

  if ctrl.mode == "save" then
    for el = 0, 15 do
      local slot = el + 1
      local rgb, inten, pri = c.slot_empty, 35, 10
      if self.storage:occupied(slot) then
        rgb, inten = c.slot_full, 100
      end
      if self.loaded_slot == slot then
        rgb, inten, pri = c.slot_loaded, 127, 60
      end
      if ctrl.save_arm then
        -- amber wash over empties / intensify occupied
        if not self.storage:occupied(slot) then
          rgb, inten, pri = c.save_arm, 80, 80
        else
          rgb, inten, pri = c.save_arm, 127, 80
        end
      end
      if slot == ctrl.selected_slot and not ctrl.save_arm then
        inten = math.min(127, inten + 20)
      end
      self.leds:set(el, rgb[1], rgb[2], rgb[3], inten, pri, "save")
    end
    return
  end

  -- EDIT mode
  for el = 0, 7 do
    local i = el + 1
    local rgb, inten = c.voice_off, 30
    if ch.enabled[i] then
      rgb, inten = c.voice_on, 110
      if i == 1 then rgb = c.voice_root end
    end
    if ch.muted then
      rgb, inten = c.muted, 100
    end
    self.leds:set(el, rgb[1], rgb[2], rgb[3], inten, 10, "voice")
  end

  local function param(el, active)
    local rgb = active and c.param or c.voice_off
    local inten = active and 100 or 40
    if ctrl.dirty and el == 15 then
      rgb, inten = c.dirty, 110
    end
    self.leds:set(el, rgb[1], rgb[2], rgb[3], inten, 10, "param")
  end

  param(8, ch.transpose ~= 0)
  param(9, ch.octave ~= 0)
  param(10, ch.inversion ~= 0)
  param(11, ch.spread ~= 0)
  param(12, ch.strum_on)
  param(13, ch.hold)
  -- slot selector
  do
    local rgb = self.storage:occupied(ctrl.selected_slot) and c.slot_full or c.slot_empty
    if self.loaded_slot == ctrl.selected_slot then rgb = c.slot_loaded end
    self.leds:set(14, rgb[1], rgb[2], rgb[3], 100, 10, "slot")
  end
  -- mode / dirty
  do
    local rgb = ctrl.dirty and c.dirty or c.param
    self.leds:set(15, rgb[1], rgb[2], rgb[3], 90, 10, "mode")
  end
end

function App:on_setup()
  self:refresh_leds()
end

function App:on_encoder(el, value)
  self.controls:on_encoder(el, value)
end

function App:on_button(el, value)
  self.controls:on_button(el, value)
end

function App:on_timer()
  self.scheduler:tick()
  self.leds:tick()
end

return App
