local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end
config.color_scheme = 'MaterialDesignColors'
config.window_background_opacity = 0.95
config.use_ime = true
config.default_cursor_style = 'SteadyBar'
config.font_size = 16.0
config.font = wezterm.font_with_fallback {
    {
        family = "Source Han Code JP"
    },
    {
        family = "Fira Code",
        harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
    }
}

return config
