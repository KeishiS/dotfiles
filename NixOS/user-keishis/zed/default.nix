{ pkgs-unstable, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;
    userSettings = {
      tab_size = 4;
      ui_font_size = 20;
      buffer_font_size = 20;
      buffer_font_family = "JuliaMono";
      soft_wrap = "editor_width";
      buffer_font_fallbacks = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono CJK JP"
      ];
      vim_mode = true;
      theme = {
        mode = "system";
        light = "Ayu Mirage";
        dark = "One Dark";
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
