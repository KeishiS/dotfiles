{ pkgs, ... }:
{
  services.n8n = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    nodejs_24
  ];
}
