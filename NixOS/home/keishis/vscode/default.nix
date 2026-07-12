{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    profiles.default = {
      userSettings = {
        "editor.fontFamily" = "'Moralerspace Krypton', monospace";
        "editor.fontSize" = 18;
        "editor.fontLigatures" =
          "'liga', 'calt', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'ss09', 'ss10'";
        "editor.minimap.enabled" = false;
        "remote.SSH.enableRemoteCommand" = true;
        "remote.SSH.useExecServer" = false;
        "workbench.startupEditor" = "none";
      };
    };
  };
}
