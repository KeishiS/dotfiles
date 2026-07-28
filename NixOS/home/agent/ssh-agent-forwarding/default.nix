{
  config,
  lib,
  pkgs,
  ...
}:
let
  forwardedAgentDirectory = "${config.home.homeDirectory}/.ssh/agent";
  forwardedAgentSocket = "${forwardedAgentDirectory}/current";

  updateForwardedAgentSocket = pkgs.writeShellApplication {
    name = "update-forwarded-ssh-agent-socket";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.util-linux
    ];
    text = builtins.readFile ../scripts/update-forwarded-ssh-agent-socket.sh;
  };

  updateCommand = lib.concatStringsSep " " [
    "${updateForwardedAgentSocket}/bin/update-forwarded-ssh-agent-socket"
    (lib.escapeShellArg forwardedAgentDirectory)
    (lib.escapeShellArg forwardedAgentSocket)
  ];
in
{
  home.sessionVariables.SSH_AUTH_SOCK = forwardedAgentSocket;

  programs.zsh.initContent = lib.mkBefore ''
    ${updateCommand}
    export SSH_AUTH_SOCK=${lib.escapeShellArg forwardedAgentSocket}
  '';

  systemd.user.services.update-forwarded-ssh-agent-socket = {
    Unit.Description = "転送されたSSH agentソケットの固定リンク更新";

    Service = {
      Type = "oneshot";
      ExecStart = updateCommand;
    };
  };

  systemd.user.paths.update-forwarded-ssh-agent-socket = {
    Unit.Description = "転送されたSSH agentソケットの変更監視";

    Path = {
      PathChanged = forwardedAgentDirectory;
      Unit = "update-forwarded-ssh-agent-socket.service";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
