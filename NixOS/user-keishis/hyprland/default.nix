{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      bind = [
        "$mod, Return, exec, ghostty"
        "$mod, d, exec, wofi -S run"
      ];

      input = {
        kb_layout = "jp";
      };
    };
  };
}
