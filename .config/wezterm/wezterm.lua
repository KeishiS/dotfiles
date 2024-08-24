local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end
--[[ config.color_scheme = 'MaterialDesignColors' ]]
config.color_scheme = 'Tokyo Night'
config.window_background_opacity = 0.8
config.use_ime = true
config.default_cursor_style = 'SteadyBar'
config.font_size = 14.0
config.font = wezterm.font_with_fallback {
    {
        family = "JetBrains Mono"
    },
    {
        family = "Fira Code",
        harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
    }
}

return config
