{ config, ... }:
{
  sops.gnupg.home = "${config.home.homeDirectory}/.gnupg";
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
