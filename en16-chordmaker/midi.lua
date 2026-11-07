-- MIDI note manager with pitch reference counting (duplicate-safe).

local Midi = {}
Midi.__index = Midi

function Midi.new(adapter, opts)
  opts = opts or {}
  local self = setmetatable({}, Midi)
  self.adapter = adapter
  self.channel = opts.channel or 0
  self.velocity = opts.velocity or 100
  self.refs = {} -- [note] = count
  self.queue = {} -- optional spacing queue
  return self
end

function Midi:set_velocity(v)
  if v < 1 then v = 1 end
  if v > 127 then v = 127 end
  self.velocity = v
end

function Midi:note_on(note)
  if note < 0 or note > 127 then return end
  local c = self.refs[note] or 0
  if c == 0 then
    self.adapter.note_on(self.channel, note, self.velocity)
  end
  self.refs[note] = c + 1
end

function Midi:note_off(note)
  if note < 0 or note > 127 then return end
  local c = self.refs[note] or 0
  if c <= 0 then return end
  c = c - 1
  if c == 0 then
    self.adapter.note_off(self.channel, note, 0)
    self.refs[note] = nil
  else
    self.refs[note] = c
  end
end

function Midi:replace(old_note, new_note)
  if old_note == new_note then return end
  if old_note then self:note_off(old_note) end
  if new_note then self:note_on(new_note) end
end

function Midi:all_off()
  for note, _ in pairs(self.refs) do
    self.adapter.note_off(self.channel, note, 0)
  end
  self.refs = {}
end

function Midi:panic()
  self:all_off()
  -- CC 123 All Notes Off + CC 120 All Sound Off
  self.adapter.midi_send(self.channel, 176, 123, 0)
  self.adapter.midi_send(self.channel, 176, 120, 0)
end

function Midi:is_sounding(note)
  return (self.refs[note] or 0) > 0
end

return Midi
