{ lib, pkgs, ... }:
{
  imports = [
    ./common.nix
    ./agent-config
    ./agent-tools
  ];

  home.homeDirectory = "/home/agent";

  home.packages = with pkgs; [
    gawk
    gh
    gnugrep
    ocrmypdf
    poppler-utils
    procps
    (tesseract.override {
      enableLanguages = [
        "eng"
        "jpn"
      ];
    })
  ];

  programs.bash.initExtra = lib.mkAfter ''
    github_token_file="$HOME/.config/gh/token"
    if [[ -r "$github_token_file" ]]; then
      export GH_TOKEN="$(<"$github_token_file")"
    fi
    unset github_token_file
  '';
}
