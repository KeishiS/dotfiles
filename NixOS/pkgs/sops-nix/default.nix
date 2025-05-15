{ ... }:
{
  # fileSystems."/etc/ssh".neededForBoot = true;
  sops.age.sshKeyPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  # /etc/hosts
  sops.secrets.hosts = {
    format = "binary";
    sopsFile = ./secrets/hosts.enc;
    mode = "0444";
    path = "/etc/hosts";
  };
  networking.extraHosts = "";
  networking.hostFiles = [ ];

  # wireless
  sops.secrets.wireless = {
    format = "binary";
    sopsFile = ./secrets/wireless.conf;
    mode = "0400";
  };
}
