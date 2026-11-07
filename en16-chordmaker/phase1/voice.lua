-- Phase 1 single-voice engine (host-testable).
-- Endless encoder scrolls chromatically across the full MIDI range (all octaves).
-- Button toggles sustain (Note On held / Note Off).

local Voice = {}
Voice.__index = Voice

local function clamp(n, lo, hi)
  if n < lo then return lo end
  if n > hi then return hi end
  return n
end

function Voice.new(opts)
  opts = opts or {}
  local self = setmetatable({}, Voice)
  self.channel = opts.channel or 0
  self.velocity = opts.velocity or 100
  self.note_min = opts.note_min or 0
  self.note_max = opts.note_max or 127
  self.note = clamp(opts.default_note or 60, self.note_min, self.note_max)
  self.sustaining = false
  self.adapter = opts.adapter
  assert(self.adapter, "adapter required")
  return self
end

function Voice:set_note(note)
  note = clamp(math.floor(note + 0.5), self.note_min, self.note_max)
  if note == self.note then
    return self.note
  end
  local old = self.note
  if self.sustaining then
    -- Retigger safely: off old, on new (same voice identity).
    self.adapter.note_off(self.channel, old, 0)
    self.note = note
    self.adapter.note_on(self.channel, self.note, self.velocity)
  else
    self.note = note
  end
  return self.note
end

-- Absolute encoder path: encoder value 0..127 maps 1:1 to MIDI note (spans ~10 octaves).
function Voice:set_note_from_encoder(encoder_value)
  return self:set_note(encoder_value)
end

-- Relative step path: +/- N semitones per detent (also crosses octaves freely).
function Voice:nudge(semitones)
  return self:set_note(self.note + semitones)
end

function Voice:sustain_on()
  if self.sustaining then
    return
  end
  self.sustaining = true
  self.adapter.note_on(self.channel, self.note, self.velocity)
end

function Voice:sustain_off()
  if not self.sustaining then
    return
  end
  self.sustaining = false
  self.adapter.note_off(self.channel, self.note, 0)
end

function Voice:toggle_sustain()
  if self.sustaining then
    self:sustain_off()
  else
    self:sustain_on()
  end
  return self.sustaining
end

function Voice:panic()
  if self.sustaining then
    self.adapter.note_off(self.channel, self.note, 0)
  end
  -- Belt-and-braces All Notes Off CC on this channel.
  self.adapter.midi_send(self.channel, 176, 123, 0)
  self.sustaining = false
end

return Voice
