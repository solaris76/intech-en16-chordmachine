-- Encoder / button routing for Edit and Save/Recall modes.

local Controls = {}
Controls.__index = Controls

local MODE_EDIT = "edit"
local MODE_SAVE = "save"

function Controls.new(app)
  local self = setmetatable({}, Controls)
  self.app = app
  self.mode = MODE_EDIT
  self.save_arm = false
  self.selected_slot = 1 -- 1..16
  self.dirty = false
  self.last_enc = {}
  return self
end

function Controls:enter_save()
  self.mode = MODE_SAVE
  self.save_arm = false
  self.app:refresh_leds()
end

function Controls:exit_save()
  self.mode = MODE_EDIT
  self.save_arm = false
  self.app:refresh_leds()
end

local function delta_from_abs(self, el, value)
  local prev = self.last_enc[el]
  self.last_enc[el] = value
  if prev == nil then return 0 end
  local d = value - prev
  if d > 64 then d = d - 128 end
  if d < -64 then d = d + 128 end
  return d
end

local function slot_from_enc(value)
  local s = math.floor(value / 8) + 1
  if s < 1 then s = 1 end
  if s > 16 then s = 16 end
  return s
end

function Controls:on_encoder(el, value)
  local app = self.app
  local ch = app.chord
  local d = delta_from_abs(self, el, value)

  if self.mode == MODE_SAVE then
    if el == app.cfg.el_mode then
      self:exit_save()
      return
    end
    if el == app.cfg.el_slot then
      self.selected_slot = slot_from_enc(value)
      app:refresh_leds()
    end
    return
  end

  -- EDIT: voices 0..7 absolute pitch (endless scroll through octaves)
  if el >= 0 and el <= 7 then
    ch:set_voice_note(el + 1, value)
    self.dirty = true
    app:refresh_leds()
    return
  end

  if d == 0 then return end

  if el == 8 then
    ch:set_transpose(ch.transpose + d)
  elseif el == 9 then
    ch:set_octave(ch.octave + (d > 0 and 1 or -1))
  elseif el == 10 then
    ch:set_inversion(ch.inversion + (d > 0 and 1 or -1))
  elseif el == 11 then
    ch:set_spread(ch.spread + d)
  elseif el == 12 then
    ch:set_strum(ch.strum_ms + d * 5)
  elseif el == 13 then
    ch:set_gate(ch.gate_ms + d * 20)
  elseif el == 14 then
    self.selected_slot = slot_from_enc(value)
    app:refresh_leds()
    return
  elseif el == 15 then
    app.midi:set_velocity(app.midi.velocity + d)
  end

  if el ~= 14 then self.dirty = true end
  app:refresh_leds()
end

function Controls:on_button(el, value)
  if value == 0 then return end
  local app = self.app
  local ch = app.chord

  if self.mode == MODE_SAVE then
    self:_save_mode_button(el)
    return
  end

  if el >= 0 and el <= 7 then
    ch:toggle_voice(el + 1)
    self.dirty = true
    app:refresh_leds()
    return
  end

  if el == 8 then
    ch:set_transpose(0)
  elseif el == 9 then
    ch:set_octave(0)
  elseif el == 10 then
    ch:set_inversion(0)
  elseif el == 11 then
    ch:set_spread(0)
  elseif el == 12 then
    ch:toggle_strum()
  elseif el == 13 then
    -- Hold / sustain chord toggle (play or release)
    ch:toggle_hold()
    if ch.hold then
      ch:trigger()
    else
      ch:release()
    end
  elseif el == 14 then
    app:recall_slot(self.selected_slot)
    app:refresh_leds()
    return
  elseif el == 15 then
    self:enter_save()
    return
  end

  self.dirty = true
  app:refresh_leds()
end

function Controls:_save_mode_button(el)
  local app = self.app

  -- enc16: armed -> save slot 16; else exit
  if el == app.cfg.el_mode then
    if self.save_arm then
      app:save_slot(16)
      self.save_arm = false
    else
      self:exit_save()
    end
    app:refresh_leds()
    return
  end

  -- enc15: toggle save-arm (prevents silent overwrite)
  if el == app.cfg.el_slot then
    self.save_arm = not self.save_arm
    app:refresh_leds()
    return
  end

  local slot = el + 1
  if self.save_arm then
    if app.storage:occupied(slot) then
      -- armed = overwrite confirmed
      app:save_slot(slot)
    else
      app:save_slot(slot)
    end
    self.save_arm = false
    app.leds:flash(el, 0, 255, 80, 127, 250)
  else
    if not app.storage:occupied(slot) then
      app.leds:flash(el, 255, 0, 0, 127, 200)
    else
      app:recall_slot(slot)
    end
  end
  app:refresh_leds()
end

Controls.MODE_EDIT = MODE_EDIT
Controls.MODE_SAVE = MODE_SAVE

return Controls
