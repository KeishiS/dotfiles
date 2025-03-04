{ ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      --[[ config.color_scheme = 'MaterialDesignColors' ]]
      config.front_end="WebGpu" -- workaround
      config.color_scheme = 'Tokyo Night'
      config.window_background_opacity = 0.8
      config.use_ime = true
      config.default_cursor_style = 'SteadyBar'
      config.font_size = 16.0
      config.font = wezterm.font_with_fallback {
        {
          family = "Monaspace Krypton"
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
        colors = { "#000000" }
      }
      config.colors = {
        tab_bar = {
          inactive_tab_edge = "none",
          active_tab = {
            fg_color = "#16161e",
            bg_color = "#7aa2f7",
          },
          inactive_tab = {
            fg_color = "#545c7e",
            bg_color = "#292e42",
          },
        }
      }

      return config
    '';
  };
}
