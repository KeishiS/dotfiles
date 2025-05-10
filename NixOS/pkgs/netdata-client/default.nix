{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  services.netdata = {
    enable = true;
    config = {
      global = {
        "memory mode" = "ram";
        timezone = "Asia/Tokyo";
      };
    };
    configDir."stream.conf" = pkgs.writeText "stream.conf" ''
      [stream]
        enabled = yes
    '';
  };
}
