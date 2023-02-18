local wezterm = require 'wezterm'

return {
    use_ime = true,
    font = wezterm.font_with_fallback {
        'Fira Code', 'Noto Sans Mono CJK JP', 'Material Design Icons'
    },
    default_cursor_style = 'SteadyBar',
    window_background_opacity = 0.8,
    
    leader = { key = 'r', mods = 'CTRL', timeout_milliseconds = 1000 },
    keys = {
        {
            key = 'h',
            mods = 'LEADER',
            action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
        },
        {
            key = 'v',
            mods = 'LEADER',
            action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
        },

        {
            key = 's',
            mods = 'LEADER',
            action = wezterm.action.ActivatePaneDirection 'Left'
        },
        {
            key = 'd',
            mods = 'LEADER',
            action = wezterm.action.ActivatePaneDirection 'Down'
        },
        {
            key = 'f',
            mods = 'LEADER',
            action = wezterm.action.ActivatePaneDirection 'Up'
        },
        {
            key = 'g',
            mods = 'LEADER',
            action = wezterm.action.ActivatePaneDirection 'Right'
        },

        {
            key = 'n',
            mods = 'LEADER',
            action = wezterm.action.SpawnTab 'DefaultDomain'
        },
        {
            key = 'o',
            mods = 'LEADER',
            action = wezterm.action.ActivateTabRelative(1)
        },
    }
}
