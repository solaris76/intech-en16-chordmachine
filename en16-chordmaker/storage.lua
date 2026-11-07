-- 16-slot chord bank. Session RAM by default; file adapter optional/unverified on Grid.

local Storage = {}
Storage.__index = Storage

local function copy(s)
  if not s then return nil end
  local n = {
    notes = {},
    enabled = {},
    transpose = s.transpose,
    octave = s.octave,
    inversion = s.inversion,
    spread = s.spread,
    strum_ms = s.strum_ms,
    strum_on = s.strum_on,
    gate_ms = s.gate_ms,
    hold = s.hold,
    scale_idx = s.scale_idx,
    velocity = s.velocity,
    name = s.name,
  }
  for i = 1, #s.notes do n.notes[i] = s.notes[i] end
  for i = 1, #s.enabled do n.enabled[i] = s.enabled[i] end
  return n
end

function Storage.new(opts)
  opts = opts or {}
  local self = setmetatable({}, Storage)
  self.slots = opts.slots or 16
  self.version = opts.version or 1
  self.bank = {}
  self.file_io = opts.file_io -- { read=fn, write=fn } or nil
  self.path = opts.path or "chordmaker_bank_v1.lua"
  for i = 1, self.slots do
    self.bank[i] = nil
  end
  return self
end

function Storage:occupied(i)
  return self.bank[i] ~= nil
end

function Storage:get(i)
  return copy(self.bank[i])
end

function Storage:save(i, snapshot)
  if i < 1 or i > self.slots then return false, "bad slot" end
  self.bank[i] = copy(snapshot)
  self.bank[i].name = self.bank[i].name ~= "" and self.bank[i].name or ("Chord " .. i)
  return true
end

function Storage:delete(i)
  if i < 1 or i > self.slots then return false end
  self.bank[i] = nil
  return true
end

function Storage:save_bank()
  if not self.file_io or not self.file_io.write then
    return false, "runtime file write unverified — session memory only"
  end
  local payload = {
    version = self.version,
    slots = {},
  }
  for i = 1, self.slots do
    payload.slots[i] = copy(self.bank[i])
  end
  return self.file_io.write(self.path, payload)
end

function Storage:load_bank()
  if not self.file_io or not self.file_io.read then
    return false, "runtime file read unverified — session memory only"
  end
  local ok, data = self.file_io.read(self.path)
  if not ok then return false, data end
  if type(data) ~= "table" or data.version ~= self.version then
    return false, "bank version mismatch"
  end
  for i = 1, self.slots do
    self.bank[i] = copy(data.slots and data.slots[i] or nil)
  end
  return true
end

-- Serialise bank as a Lua table literal string for Grid Editor export/import.
function Storage:export_lua()
  local function ser(v)
    local t = type(v)
    if t == "nil" then return "nil" end
    if t == "boolean" then return v and "true" or "false" end
    if t == "number" then return tostring(v) end
    if t == "string" then return string.format("%q", v) end
    if t == "table" then
      local parts = {}
      local n = #v
      local is_arr = n > 0
      if is_arr then
        for i = 1, n do parts[i] = ser(v[i]) end
        return "{" .. table.concat(parts, ",") .. "}"
      end
      for k, val in pairs(v) do
        parts[#parts + 1] = "[" .. ser(k) .. "]=" .. ser(val)
      end
      return "{" .. table.concat(parts, ",") .. "}"
    end
    return "nil"
  end
  local slots = {}
  for i = 1, self.slots do
    slots[i] = self.bank[i]
  end
  return "return {version=" .. self.version .. ",slots=" .. ser(slots) .. "}"
end

function Storage:import_lua(src)
  local fn, err = load(src)
  if not fn then return false, err end
  local data = fn()
  if type(data) ~= "table" or data.version ~= self.version then
    return false, "invalid bank"
  end
  for i = 1, self.slots do
    self.bank[i] = copy(data.slots and data.slots[i] or nil)
  end
  return true
end

return Storage
