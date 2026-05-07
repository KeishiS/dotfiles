{
  imports = [
    ./server.nix
    ./backup.nix
  ];

  sops.secrets.db-sandi05-acme = {
    format = "yaml";
    sopsFile = ./secrets/cloudflare.enc.yaml;
    mode = "0400";
    owner = "acme";
    group = "acme";
  };

  services.homePostgresqlBackup = {
    enable = true;
    databases = [
      "postgres"
    ];
    ageRecipients = [
      "age1yubikey1qgauag3cngkm8u23h4r42ekn5ng2a7rmqqpspurz6kcuu9sqkhhgg62m0dc"
    ];
    calendar = "Sun 02:00";
  };
}
