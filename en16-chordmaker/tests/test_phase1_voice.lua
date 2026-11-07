#!/usr/bin/env lua
-- Run from en16-chordmaker/: lua tests/test_phase1_voice.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local Voice = require("phase1.voice")
local Mock = require("tests.mock_adapter")

local failed = 0

local function assert_eq(a, b, msg)
  if a ~= b then
    failed = failed + 1
    print("FAIL:", msg, "got", tostring(a), "expected", tostring(b))
  else
    print("ok:", msg)
  end
end

local function assert_true(cond, msg)
  if not cond then
    failed = failed + 1
    print("FAIL:", msg)
  else
    print("ok:", msg)
  end
end

-- Pitch + octave scroll via absolute mapping
do
  local a = Mock.new()
  local v = Voice.new({ adapter = a, default_note = 60 })
  v:set_note_from_encoder(72) -- C5, one octave up
  assert_eq(v.note, 72, "encoder maps across octave")
  v:set_note_from_encoder(48) -- C3
  assert_eq(v.note, 48, "encoder maps down octaves")
  v:set_note_from_encoder(-5)
  assert_eq(v.note, 0, "clamps low")
  v:set_note_from_encoder(200)
  assert_eq(v.note, 127, "clamps high")
end

-- Relative nudge across octave boundary
do
  local a = Mock.new()
  local v = Voice.new({ adapter = a, default_note = 59 })
  v:nudge(1)
  assert_eq(v.note, 60, "nudge crosses into next octave pitch")
end

-- Sustain toggle Note On / Off
do
  local a = Mock.new()
  local v = Voice.new({ adapter = a, default_note = 60, velocity = 100 })
  assert_eq(v:toggle_sustain(), true, "sustain on")
  assert_eq(#Mock.find_midi(a.log, 144, 60), 1, "note on sent")
  assert_eq(v:toggle_sustain(), false, "sustain off")
  assert_eq(#Mock.find_midi(a.log, 128, 60), 1, "note off sent")
end

-- Pitch change while sustaining retriggers only that voice
do
  local a = Mock.new()
  local v = Voice.new({ adapter = a, default_note = 60 })
  v:sustain_on()
  a.log = {}
  v:set_note(64)
  local offs = Mock.find_midi(a.log, 128, 60)
  local ons = Mock.find_midi(a.log, 144, 64)
  assert_eq(#offs, 1, "old note off while sustaining")
  assert_eq(#ons, 1, "new note on while sustaining")
  assert_eq(v.note, 64, "pitch updated")
end

-- Pitch change while not sustaining sends nothing
do
  local a = Mock.new()
  local v = Voice.new({ adapter = a, default_note = 60 })
  v:set_note(67)
  assert_eq(#a.log, 0, "silent pitch edit when not sustaining")
end

-- Panic
do
  local a = Mock.new()
  local v = Voice.new({ adapter = a, default_note = 60 })
  v:sustain_on()
  v:panic()
  assert_eq(v.sustaining, false, "panic clears sustain")
  assert_true(#Mock.find_midi(a.log, 176, nil) >= 1 or #Mock.find_midi(a.log, 128, 60) >= 1, "panic midi emitted")
end

if failed > 0 then
  print(failed .. " failure(s)")
  os.exit(1)
end
print("all phase1 voice tests passed")
