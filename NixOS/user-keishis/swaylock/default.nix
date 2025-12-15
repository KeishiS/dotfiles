{ ... }: let
  theme = (import ../theme);
in {
  programs.swaylock = {
    enable = true;
    settings = {
      # Background
      color = theme.background;

      # Font
      font-size = 24;

      # Effects
      effect-blur = "13x13";
      effect-vignette = "0.5:0.5";

      # Indicator
      indicator-radius = 200;
      indicator-thickness = 20;

      # Default state colors
      inside-color = theme.background-alt;
      line-color = theme.border;
      ring-color = theme.semantic.primary;
      text-color = theme.foreground;

      # Verifying state
      inside-ver-color = theme.background-alt;
      line-ver-color = theme.border;
      ring-ver-color = theme.semantic.info;
      text-ver-color = theme.foreground;

      # Wrong password state
      inside-wrong-color = theme.background-alt;
      line-wrong-color = theme.border;
      ring-wrong-color = theme.semantic.error;
      text-wrong-color = theme.semantic.error;

      # Clear state
      inside-clear-color = theme.background-alt;
      line-clear-color = theme.border;
      ring-clear-color = theme.semantic.warning;
      text-clear-color = theme.foreground;

      # Caps lock state
      caps-lock-bs-hl-color = theme.semantic.warning;
      caps-lock-key-hl-color = theme.semantic.warning;

      # Key highlight
      key-hl-color = theme.semantic.success;
      bs-hl-color = theme.semantic.urgent;

      # Separator color
      separator-color = theme.border;
    };
  };
}
