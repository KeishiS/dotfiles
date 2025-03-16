{ my-secrets, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  age.secrets = {
    "mackerel_apikey" = {
      file = "${my-secrets}/mackerel_apikey.age";
      mode = "0400";
      owner = "root";
      group = "root";
    };

    /*
      techadmin = {
        file = "${my-secrets}/homelab/techadmin.age";
        path = "/run/ragenix/homelab/techadmin";
        mode = "0440";
        owner = "portunus";
        group = "nslcd";
      };

      keishis = {
        file = "${my-secrets}/homelab/keishis.age";
        path = "/run/ragenix/homelab/keishis";
        mode = "0440";
        owner = "portunus";
        group = "nslcd";
      };
    */
  };

  networking.hostName = "NixOS-sandi-N100";
  services.openssh = {
    extraConfig = ''
      AllowAgentForwarding yes
    '';
  };
  system.stateVersion = "24.11";
}
