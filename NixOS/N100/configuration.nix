{ my-secrets, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  age.secrets."mackerel_apikey" = {
    file = "${my-secrets}/mackerel_apikey.age";
    mode = "0400";
    owner = "root";
    group = "root";
  };

  networking.hostName = "NixOS-sandi-N100";
  services.openssh = {
    extraConfig = ''
      AllowAgentForwarding yes
      StreamLocalBindUnlink yes
    '';
  };
}
