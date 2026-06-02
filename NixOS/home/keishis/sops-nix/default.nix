{
  config,
  lib,
  ...
}:
{
  sops.gnupg.home = "${config.home.homeDirectory}/.gnupg";

  systemd.user.services.sops-nix.Install.WantedBy = lib.mkForce [ ];

  sops.secrets = {
    ssh_config = {
      format = "binary";
      sopsFile = ./secrets/ssh-config.enc;
      path = "${config.home.homeDirectory}/.ssh/config";
    };

    pypi = {
      format = "binary";
      sopsFile = ./secrets/pypirc.enc;
      path = "${config.home.homeDirectory}/.pypirc";
      mode = "0400";
    };
  };
}
