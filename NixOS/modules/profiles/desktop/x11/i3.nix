{ ... }:
{
  imports = [
    ./default.nix
  ];

  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
}
