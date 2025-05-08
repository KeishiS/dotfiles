{ config, ... }:
{
  sops.gnupg.home = "${config.home.homeDirectory}/.gnupg";
  sops.secrets = {
    test = {
      sopsFile = "./secrets/ssh-config.enc";
    };
  };
}
