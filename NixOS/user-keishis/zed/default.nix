{ pkgs, pkgs-unstable, ... }:
let
  theme = (import ../theme);
in
{
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;
    extensions = [
      "nix"
      "ltex"
    ];

    # Aquarium theme
    themes = {
      aquarium = ./aquarium.json;
    };

    userSettings = {
      tab_size = 4;
      ui_font_size = 20;
      buffer_font_size = 20;
      buffer_font_family = theme.font.console;
      buffer_font_fallbacks = [
        "JuliaMono"
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono CJK JP"
      ];
      buffer_font_features = {
        calt = true;
        liga = true;
        ss02 = true;
        ss03 = true;
        ss04 = true;
        ss05 = true;
        zero = true;
      };
      soft_wrap = "editor_width";
      vim_mode = true;
      theme = {
        mode = "system";
        light = "Ayu Light";
        dark = "Aquarium";
      };
      features = {
        edit_prediction_provider = "copilot";
      };
      inlay_hints = {
        enabled = true;
        show_type_hints = true;
        show_parameter_hints = true;
        show_other_hints = true;
      };
      format_on_save = "on";
      terminal = {
        program = pkgs.zsh;
      };

      languages = {
        Nix = {
          language_servers = [ "nixd" ];
          formatter.external.command = "nixfmt";
        };

        "Shell Script" = {
          hard_tabs = false;
          formatter.external.command = "shfmt";
        };
      };
    };
  };
}
