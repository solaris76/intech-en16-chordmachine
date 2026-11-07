#!/usr/bin/env lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local Mock = require("tests.mock_adapter")
local App = require("chordmaker")

local failed = 0
local function ok(cond, msg)
  if cond then print("ok:", msg) else failed = failed + 1 print("FAIL:", msg) end
end
local function eq(a, b, msg)
  ok(a == b, msg .. " (" .. tostring(a) .. " vs " .. tostring(b) .. ")")
end

local function midi_count(log, cmd, note)
  local n = 0
  for _, e in ipairs(log) do
    if e[1] == "midi" and e[3] == cmd and (note == nil or e[4] == note) then n = n + 1 end
  end
  return n
end

-- Pitch / octaves
do
  local a = Mock.new()
  local app = App.new({ adapter = a, clock_ms = function() return 0 end })
  app:on_encoder(0, 72)
  eq(app.chord.notes[1], 72, "voice1 octave up")
  app:on_encoder(0, 48)
  eq(app.chord.notes[1], 48, "voice1 octave down")
end

-- Boundaries
do
  local a = Mock.new()
  local app = App.new({ adapter = a, clock_ms = function() return 0 end })
  app:on_encoder(0, -3)
  eq(app.chord.notes[1], 0, "clamp low")
  app:on_encoder(0, 200)
  eq(app.chord.notes[1], 127, "clamp high")
end

-- Voice toggle + duplicate refcount
do
  local a = Mock.new()
  local app = App.new({ adapter = a, clock_ms = function() return 0 end })
  app.chord.notes[1] = 60
  app.chord.notes[2] = 60
  app.chord.enabled[1] = true
  app.chord.enabled[2] = true
  app.chord:trigger()
  eq(midi_count(a.log, 144, 60), 1, "duplicate pitch one Note On")
  app.chord:toggle_voice(1)
  eq(midi_count(a.log, 128, 60), 0, "refcount keeps note while voice2 holds")
  app.chord:toggle_voice(2)
  eq(midi_count(a.log, 128, 60), 1, "note off after last voice")
end

-- Transpose / inversion
do
  local a = Mock.new()
  local app = App.new({ adapter = a, clock_ms = function() return 0 end })
  app.chord:set_transpose(2)
  local c = app.chord:compute()
  eq(c[1], 50, "transpose +2 from 48")
  app.chord:set_inversion(1)
  c = app.chord:compute()
  ok(c[1] ~= nil, "inversion still yields voice1")
end

-- Save / recall / empty / overwrite arm
do
  local a = Mock.new()
  local app = App.new({ adapter = a, clock_ms = function() return 0 end })
  app.chord.notes[1] = 55
  ok(app:save_slot(1), "save slot1")
  app.chord.notes[1] = 60
  ok(app:recall_slot(1), "recall slot1")
  eq(app.chord.notes[1], 55, "recalled pitch")
  ok(app:recall_slot(2) == false, "empty slot fails")
  app.controls:enter_save()
  eq(app.controls.mode, "save", "save mode")
  app.controls.save_arm = true
  app.controls:_save_mode_button(0) -- overwrite/save slot1
  ok(app.storage:occupied(1), "slot still occupied after armed save")
end

-- Panic
do
  local a = Mock.new()
  local app = App.new({ adapter = a, clock_ms = function() return 0 end })
  app.chord:trigger()
  app:panic()
  ok(midi_count(a.log, 176) >= 1, "panic CC")
  eq(app.chord:is_held(), false, "released")
end

-- Hold button (enc14 index 13)
do
  local a = Mock.new()
  local app = App.new({ adapter = a, clock_ms = function() return 0 end })
  app.chord.hold = false
  app:on_button(13, 127)
  ok(app.chord.hold == true, "hold on")
  ok(app.chord:is_held(), "chord sounding")
  app:on_button(13, 127)
  ok(app.chord.hold == false, "hold off")
end

-- Mode enter enc16
do
  local a = Mock.new()
  local app = App.new({ adapter = a, clock_ms = function() return 0 end })
  app:on_button(15, 127)
  eq(app.controls.mode, "save", "enter save/recall")
end

if failed > 0 then
  print(failed .. " failures")
  os.exit(1)
end
print("all chordmaker tests passed")
