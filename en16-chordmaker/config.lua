-- Shared configuration for EN16 Chord Maker (host + device mirror).

local Config = {
  midi_channel = 0, -- Grid 0 == MIDI channel 1
  velocity = 100,
  note_min = 0,
  note_max = 127,
  voices = 8,
  slots = 16,

  octave_min = -3,
  octave_max = 3,
  inversion_min = 0,
  inversion_max = 7,
  spread_min = 0,
  spread_max = 24,
  strum_min_ms = 0,
  strum_max_ms = 250,
  gate_min_ms = 20,
  gate_max_ms = 2000,

  led_layer_button = 1,
  led_layer_encoder = 2,

  -- Element indices 0..15
  el_slot = 14, -- enc 15: select slot / recall (edit); save-arm toggle (save mode)
  el_mode = 15, -- enc 16: enter/exit Save/Recall

  colors = {
    voice_on = {0, 220, 0},
    voice_off = {35, 35, 35},
    voice_root = {0, 80, 255},
    param = {255, 160, 0},
    muted = {220, 0, 0},
    dirty = {180, 0, 220},
    slot_full = {0, 200, 0},
    slot_empty = {35, 35, 35},
    slot_loaded = {0, 80, 255},
    save_arm = {255, 160, 0},
    warn = {255, 0, 0},
    ok = {0, 255, 80},
  },

  -- Default Cmin7-ish voicing (4 on, 4 off)
  default_notes = {48, 51, 55, 58, 62, 67, 72, 75},
  default_enabled = {true, true, true, true, false, false, false, false},

  bank_version = 1,
}

return Config
