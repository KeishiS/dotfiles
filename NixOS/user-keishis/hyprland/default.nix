{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "mod, Return, exec, ghostty"
      ];
    };
  };
}
