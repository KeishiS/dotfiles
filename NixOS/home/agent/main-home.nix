{
  imports = [
    ./common.nix
    ./git
    ./sandbox-workdir.nix
  ];

  home.homeDirectory = "/users/agent";
}
