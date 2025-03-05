{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      bind = [
        "$mod, Return, exec, ghostty"
      ];

      input = {
        kb_layout = "jp";
      };
    };
  };
}
