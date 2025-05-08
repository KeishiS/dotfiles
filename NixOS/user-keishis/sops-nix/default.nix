{ ... }:
{
  sops.secrets = {
    test = {
      sopsFile = "./../secrets/ssh-config.enc";
    };
  };
}
