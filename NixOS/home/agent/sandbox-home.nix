{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./agent-config
    ./agent-tools
  ];

  home.homeDirectory = "/home/agent";

  home.packages = with pkgs; [
    gawk
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
}
