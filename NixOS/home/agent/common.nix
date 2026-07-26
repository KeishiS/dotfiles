{ pkgs, ... }:
{
  imports = [
    # ./shell
    # ./starship
    ./vim
  ];

  home = {
    stateVersion = "26.05";

    sessionPath = [ "$HOME/.local/bin" ];

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  programs.home-manager.enable = true;
}
