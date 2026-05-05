{ ... }:
let
  theme = (import ../theme);
in
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      config.front_end = "WebGpu" -- workaround
      config.window_background_opacity = 0.8
      config.use_ime = true
      config.default_cursor_style = 'SteadyBar'
      config.font_size = 16.0
      config.font = wezterm.font_with_fallback {
        {
          family = "${theme.font.console}"
        },
        {
          family = "JuliaMono"
        },
        {
          family = "Noto Sans Mono CJK JP"
        }
      }

      config.leader = {
        mods = 'CTRL',
        key = 'q',
        timeout_milliseconds = 1000,
      }
      config.keys = {
        {
          --[[ Create New Tab ]]
          mods = 'LEADER',
          key = 'c',
          action = wezterm.action.SpawnTab 'CurrentPaneDomain',
        },
        {
          --[[ Move to Next Tab ]]
          mods = 'CTRL',
          key = 'Tab',
          action = wezterm.action.ActivateTabRelative(1),
        },
        {
          --[[ Move to the Previous Tab ]]
          mods = 'SHIFT',
          key = 'Tab',
          action = wezterm.action.ActivateTabRelative(-1),
        },
        {
          --[[ Divide Current Pane ]]
          mods = 'LEADER',
          key = 'h',
          action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
        },
        {
          --[[ Divide Current Pane ]]
          mods = 'LEADER',
          key = 'v',
          action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
        },
        {
          --[[ Move to Left Pane ]]
          mods = 'CTRL|SHIFT',
          key = 'h',
          action = wezterm.action.ActivatePaneDirection("Left"),
        },
        {
          --[[ Move to Right Pane ]]
          mods = 'CTRL|SHIFT',
          key = 'l',
          action = wezterm.action.ActivatePaneDirection("Right"),
        },
        {
          --[[ Move to Down Pane ]]
          mods = 'CTRL|SHIFT',
          key = 'j',
          action = wezterm.action.ActivatePaneDirection("Down"),
        },
        {
          --[[ Move to Up Pane ]]
          mods = 'CTRL|SHIFT',
          key = 'k',
          action = wezterm.action.ActivatePaneDirection("Up"),
        },
        {
          --[[ Activate Copy Mode ]]
          mods = 'LEADER',
          key = '[',
          action = wezterm.action.ActivateCopyMode,
        },
      }

      config.window_decorations = "RESIZE"
      config.show_new_tab_button_in_tab_bar = false
      config.hide_tab_bar_if_only_one_tab = true
      config.show_tab_index_in_tab_bar = false

      config.window_frame = {
        active_titlebar_bg = "none",
        inactive_titlebar_bg = "none"
      }
      config.window_background_gradient = {
        colors = { "${theme.background}" }
      }
      config.colors = {
        -- Base colors
        foreground = "${theme.foreground}",
        background = "${theme.background}",

        -- Cursor
        cursor_bg = "${theme.cursor.normal}",
        cursor_fg = "${theme.cursor.text}",
        cursor_border = "${theme.cursor.normal}",

        -- Selection
        selection_fg = "${theme.selection.foreground}",
        selection_bg = "${theme.selection.background}",

        -- ANSI colors (0-7)
        ansi = {
          "${theme.palette."0"}",  -- black
          "${theme.palette."1"}",  -- red
          "${theme.palette."2"}",  -- green
          "${theme.palette."3"}",  -- yellow
          "${theme.palette."4"}",  -- blue
          "${theme.palette."5"}",  -- magenta
          "${theme.palette."6"}",  -- cyan
          "${theme.palette."7"}",  -- white
        },

        -- Bright ANSI colors (8-15)
        brights = {
          "${theme.palette."8"}",   -- bright black
          "${theme.palette."9"}",   -- bright red
          "${theme.palette."10"}",  -- bright green
          "${theme.palette."11"}",  -- bright yellow
          "${theme.palette."12"}",  -- bright blue
          "${theme.palette."13"}",  -- bright magenta
          "${theme.palette."14"}",  -- bright cyan
          "${theme.palette."15"}",  -- bright white
        },

        -- Tab bar
        tab_bar = {
          background = "${theme.bar}",
          inactive_tab_edge = "none",
          active_tab = {
            bg_color = "${theme.tabs.active.background}",
            fg_color = "${theme.tabs.active.foreground}",
            intensity = "Bold",
          },
          inactive_tab = {
            bg_color = "${theme.tabs.background}",
            fg_color = "${theme.tabs.foreground}",
          },
          inactive_tab_hover = {
            bg_color = "${theme.background-highlight}",
            fg_color = "${theme.foreground}",
          },
          new_tab = {
            bg_color = "${theme.tabs.background}",
            fg_color = "${theme.tabs.foreground}",
          },
          new_tab_hover = {
            bg_color = "${theme.tabs.active.highlight}",
            fg_color = "${theme.background}",
          },
        }
      }

      return config
    '';
  };
}
