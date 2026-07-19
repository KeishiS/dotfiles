{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./agent-config
    ./agent-tools
  ];

  home.homeDirectory = "/home/agent";

  home.packages = with pkgs; [
    ocrmypdf
    poppler-utils
    (tesseract.override {
      enableLanguages = [
        "eng"
        "jpn"
      ];
    })
  ];
}
