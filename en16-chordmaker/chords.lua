-- Eight-voice chord engine with transpose, inversion, spread, scale quantise.

local Chords = {}
Chords.__index = Chords

local MAJOR = {0, 2, 4, 5, 7, 9, 11}
local SCALES = {
  { name = "chromatic", degrees = nil },
  { name = "major", degrees = MAJOR },
  { name = "dorian", degrees = {0, 2, 3, 5, 7, 9, 10} },
  { name = "phrygian", degrees = {0, 1, 3, 5, 7, 8, 10} },
  { name = "lydian", degrees = {0, 2, 4, 6, 7, 9, 11} },
  { name = "mixolydian", degrees = {0, 2, 4, 5, 7, 9, 10} },
  { name = "aeolian", degrees = {0, 2, 3, 5, 7, 8, 10} },
  { name = "locrian", degrees = {0, 1, 3, 5, 6, 8, 10} },
}

local function clamp(n, lo, hi)
  if n < lo then return lo end
  if n > hi then return hi end
  return n
end

local function copy_arr(a)
  local t = {}
  for i = 1, #a do t[i] = a[i] end
  return t
end

function Chords.scales()
  return SCALES
end

function Chords.new(opts)
  opts = opts or {}
  local cfg = opts.config
  local self = setmetatable({}, Chords)
  self.cfg = cfg
  self.midi = opts.midi
  self.scheduler = opts.scheduler
  self.notes = copy_arr(cfg.default_notes)
  self.enabled = {}
  for i = 1, cfg.voices do
    self.enabled[i] = cfg.default_enabled[i] and true or false
  end
  self.transpose = 0 -- semitones
  self.octave = 0
  self.inversion = 0
  self.spread = 0
  self.strum_ms = 0
  self.strum_on = false
  self.gate_ms = 400
  self.hold = true
  self.scale_idx = 1 -- chromatic
  self.sounding = {} -- voice -> midi note currently held by engine
  self.muted = false
  self.full_retrigger = false
  self._gate_jobs = {}
  return self
end

function Chords:snapshot()
  return {
    notes = copy_arr(self.notes),
    enabled = copy_arr(self.enabled),
    transpose = self.transpose,
    octave = self.octave,
    inversion = self.inversion,
    spread = self.spread,
    strum_ms = self.strum_ms,
    strum_on = self.strum_on,
    gate_ms = self.gate_ms,
    hold = self.hold,
    scale_idx = self.scale_idx,
    velocity = self.midi.velocity,
    name = self.name or "",
  }
end

function Chords:apply_snapshot(s, opts)
  opts = opts or {}
  if not s then return end
  local was = self:is_held()
  if was and not opts.keep_sounding then
    self:release()
  end
  self.notes = copy_arr(s.notes)
  self.enabled = copy_arr(s.enabled)
  self.transpose = s.transpose or 0
  self.octave = s.octave or 0
  self.inversion = s.inversion or 0
  self.spread = s.spread or 0
  self.strum_ms = s.strum_ms or 0
  self.strum_on = s.strum_on and true or false
  self.gate_ms = s.gate_ms or self.gate_ms
  self.hold = s.hold ~= false
  self.scale_idx = s.scale_idx or 1
  self.name = s.name or ""
  if s.velocity then self.midi:set_velocity(s.velocity) end
  if was or opts.play then
    self:trigger()
  end
end

function Chords:quantize(note)
  local sc = SCALES[self.scale_idx]
  if not sc or not sc.degrees then return note end
  local root = (self.notes[1] + self.transpose) % 12
  local best, bestd = note, 128
  for _, d in ipairs(sc.degrees) do
    local target_pc = (root + d) % 12
    local n = note - (note % 12) + target_pc
    if math.abs(n - note) > math.abs(n - 12 - note) then n = n - 12 end
    if math.abs(n + 12 - note) < math.abs(n - note) then n = n + 12 end
    local dist = math.abs(n - note)
    if dist < bestd then best, bestd = n, dist end
  end
  return clamp(best, 0, 127)
end

-- Build sounding pitches for enabled voices (absolute), applying musical transforms.
function Chords:compute()
  local raw = {}
  for i = 1, self.cfg.voices do
    raw[i] = self.notes[i]
  end

  -- Inversion: raise lowest N sounding pitches by an octave (among enabled)
  local order = {}
  for i = 1, self.cfg.voices do
    if self.enabled[i] then order[#order + 1] = i end
  end
  table.sort(order, function(a, b) return raw[a] < raw[b] end)
  local inv = clamp(self.inversion, 0, math.max(0, #order - 1))
  for k = 1, inv do
    local idx = order[k]
    raw[idx] = raw[idx] + 12
  end

  local out = {}
  for i = 1, self.cfg.voices do
    if self.enabled[i] then
      local n = raw[i]
        + self.transpose
        + self.octave * 12
        + self.spread * (i - 1)
      n = self:quantize(n)
      out[i] = clamp(n, 0, 127)
    else
      out[i] = nil
    end
  end
  return out
end

function Chords:is_held()
  for i = 1, self.cfg.voices do
    if self.sounding[i] then return true end
  end
  return false
end

function Chords:_clear_gate_jobs()
  for _, id in ipairs(self._gate_jobs) do
    self.scheduler:cancel(id)
  end
  self._gate_jobs = {}
end

function Chords:_voice_on(i, note, delay)
  local function go()
    if self.muted or not self.enabled[i] then return end
    local old = self.sounding[i]
    if old and old ~= note then
      self.midi:note_off(old)
    end
    if not old or old ~= note or self.full_retrigger then
      if not (old and old == note) then
        self.midi:note_on(note)
      elseif self.full_retrigger then
        self.midi:note_off(note)
        self.midi:note_on(note)
      end
    end
    self.sounding[i] = note
    if not self.hold then
      local gid = self.scheduler:after(self.gate_ms, function()
        if self.sounding[i] == note then
          self.midi:note_off(note)
          self.sounding[i] = nil
        end
      end)
      self._gate_jobs[#self._gate_jobs + 1] = gid
    end
  end
  if delay and delay > 0 then
    local id = self.scheduler:after(delay, go)
    self._gate_jobs[#self._gate_jobs + 1] = id
  else
    go()
  end
end

function Chords:_voice_off(i)
  local old = self.sounding[i]
  if old then
    self.midi:note_off(old)
    self.sounding[i] = nil
  end
end

function Chords:release()
  self:_clear_gate_jobs()
  for i = 1, self.cfg.voices do
    self:_voice_off(i)
  end
end

function Chords:trigger()
  self:_clear_gate_jobs()
  if self.muted then return end
  local target = self:compute()
  local delay = 0
  local step = (self.strum_on and self.strum_ms > 0) and self.strum_ms or 0

  -- Release voices that are no longer required
  for i = 1, self.cfg.voices do
    local want = target[i]
    local have = self.sounding[i]
    if have and not want then
      self:_voice_off(i)
    elseif have and want and self.full_retrigger then
      self:_voice_off(i)
    elseif have and want and have ~= want then
      -- pitch change handled in _voice_on
    end
  end

  for i = 1, self.cfg.voices do
    local want = target[i]
    if want then
      local have = self.sounding[i]
      if not have or have ~= want or self.full_retrigger then
        self:_voice_on(i, want, delay)
        delay = delay + step
      end
    end
  end
end

-- Smooth morph when recalling: preserve common pitches where possible.
function Chords:transition_to_snapshot(s)
  local keep = self:is_held()
  self:apply_snapshot(s, { keep_sounding = true })
  if keep or self.hold then
    self.full_retrigger = false
    self:trigger()
  end
end

function Chords:set_voice_note(i, note)
  note = clamp(math.floor(note + 0.5), 0, 127)
  if self.notes[i] == note then return end
  self.notes[i] = note
  if self.sounding[i] or (self.hold and self:is_held()) then
    local target = self:compute()
    if target[i] then
      self:_voice_on(i, target[i], 0)
    else
      self:_voice_off(i)
    end
  end
end

function Chords:nudge_voice(i, delta)
  self:set_voice_note(i, self.notes[i] + delta)
end

function Chords:toggle_voice(i)
  self.enabled[i] = not self.enabled[i]
  if self:is_held() or self.hold then
    if self.enabled[i] and self:is_held() then
      local target = self:compute()
      if target[i] then self:_voice_on(i, target[i], 0) end
    else
      self:_voice_off(i)
    end
  end
end

function Chords:set_transpose(v)
  self.transpose = clamp(v, -24, 24)
  if self:is_held() then self:trigger() end
end

function Chords:set_octave(v)
  self.octave = clamp(v, self.cfg.octave_min, self.cfg.octave_max)
  if self:is_held() then self:trigger() end
end

function Chords:set_inversion(v)
  self.inversion = clamp(v, self.cfg.inversion_min, self.cfg.inversion_max)
  if self:is_held() then self:trigger() end
end

function Chords:set_spread(v)
  self.spread = clamp(v, self.cfg.spread_min, self.cfg.spread_max)
  if self:is_held() then self:trigger() end
end

function Chords:set_strum(ms)
  self.strum_ms = clamp(ms, self.cfg.strum_min_ms, self.cfg.strum_max_ms)
end

function Chords:toggle_strum()
  self.strum_on = not self.strum_on
end

function Chords:set_gate(ms)
  self.gate_ms = clamp(ms, self.cfg.gate_min_ms, self.cfg.gate_max_ms)
end

function Chords:toggle_hold()
  self.hold = not self.hold
  if self.hold == false and self:is_held() then
    -- schedule gates from now
    self:trigger()
  end
end

function Chords:cycle_scale(delta)
  self.scale_idx = ((self.scale_idx - 1 + delta) % #SCALES) + 1
  if self:is_held() then self:trigger() end
end

function Chords:toggle_mute()
  self.muted = not self.muted
  if self.muted then
    self:release()
  end
end

return Chords
