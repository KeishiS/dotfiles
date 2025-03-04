{ ... }: let
  theme = (import ../theme);
in {
  programs.swaylock = {
    enable = true;
    settings = {
      color = theme.bg;
      font-size = 24;
      effect-blur = "13x13";
      effect-vignette = "0.5:0.5";
      indicator-radius = 200;
      indicator-thickness = 20;
    };
  };
}
