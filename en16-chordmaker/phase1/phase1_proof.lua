-- Phase 1 proof logic (runs on host with mocks, or mirrored into Grid snippets).
--
-- Hardware UX (EN16 alone, USB MIDI):
--   Bottom-right encoder (element 15, verify on device):
--     ROTATE  -> scroll MIDI note 0..127 chromatically across octaves
--     PUSH    -> toggle sustain Note On / Note Off
--
-- After Store, no computer/Editor required — only a USB MIDI host.

local Config = require("config")
local GridAdapter = require("grid_adapter")
local Voice = require("phase1.voice")

local Phase1 = {}

function Phase1.create(adapter)
  adapter = adapter or GridAdapter
  local voice = Voice.new({
    channel = Config.midi_channel,
    velocity = Config.velocity,
    default_note = Config.default_note,
    note_min = Config.note_min,
    note_max = Config.note_max,
    adapter = adapter,
  })

  local function paint(element_index)
    local led = adapter.led_address(element_index, 0)
    local rgb = voice.sustaining and Config.colors.sustain_on or Config.colors.sustain_off
    local layer = Config.led_layer_button
    adapter.led_color(led, layer, rgb[1], rgb[2], rgb[3])
    adapter.led_value(led, layer, voice.sustaining and 127 or 40)
  end

  return {
    voice = voice,
    config = Config,
    on_setup = function(element_index)
      -- Absolute 0..127 == full MIDI note range (all octaves via endless scroll).
      -- Element methods exist only on device; host tests skip them.
      paint(element_index)
    end,
    on_encoder = function(element_index, encoder_value)
      voice:set_note_from_encoder(encoder_value)
      paint(element_index)
    end,
    on_button = function(element_index, button_value)
      -- Rising edge / toggle-mode "on" step: treat non-zero as press action.
      -- Snippets use button_mode(1) toggle so each press flips 0<->127 once.
      if button_value ~= 0 then
        voice:toggle_sustain()
        paint(element_index)
      end
    end,
    panic = function()
      voice:panic()
    end,
  }
end

return Phase1
