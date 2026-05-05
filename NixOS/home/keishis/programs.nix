{ pkgs, ... }:
{
  editorconfig = {
    enable = true;
    settings."*" = {
      charset = "utf-8";
      trim_trailing_whitespace = true;
      indent_style = "space";
      indent_size = 4;
      insert_final_newline = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.nushell.enable = true;

  programs.starship.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      # obs-webkitgtk
      advanced-scene-switcher
    ];
  };
}
