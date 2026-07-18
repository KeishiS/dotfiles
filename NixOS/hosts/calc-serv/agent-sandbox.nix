{
  config,
  lib,
  pkgs,
  ...
}:
let
  sandboxRoot = "/sandbox";

  sandboxEnterRuntimeInputs = with pkgs; [
    bashInteractive
    bubblewrap
    coreutils
    glibc.bin
    nix
    util-linux
  ];

  homeHelper = pkgs.writeShellApplication {
    name = "agent-sandbox-home";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.glibc.bin
      pkgs.util-linux
    ];
    text = ''
      export AGENT_SANDBOX_ROOT=${lib.escapeShellArg sandboxRoot}
      ${builtins.readFile ./scripts/agent-sandbox-home}
    '';
  };

  sandboxEnter = pkgs.writeShellApplication {
    name = "agent-sandbox-enter";
    runtimeInputs = sandboxEnterRuntimeInputs;
    text = ''
      export AGENT_SANDBOX_BASH=${pkgs.bashInteractive}/bin/bash
      export AGENT_SANDBOX_ENV=${pkgs.coreutils}/bin/env
      export AGENT_SANDBOX_DYNAMIC_LOADER=${pkgs.glibc}/lib/ld-linux-x86-64.so.2
      export AGENT_SANDBOX_CACERT=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export AGENT_SANDBOX_RUNTIME_PATH=${lib.makeBinPath sandboxEnterRuntimeInputs}
      export AGENT_SANDBOX_ROOT=${lib.escapeShellArg sandboxRoot}
      ${builtins.readFile ./scripts/agent-sandbox-enter}
    '';
  };

  sandboxFrontend = pkgs.writeShellApplication {
    name = "agent-sandbox";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.glibc.bin
    ];
    text = ''
      export AGENT_SANDBOX_HOME_HELPER=${homeHelper}/bin/agent-sandbox-home
      export AGENT_SANDBOX_ENTER=${sandboxEnter}/bin/agent-sandbox-enter
      export AGENT_SANDBOX_ROOT=${lib.escapeShellArg sandboxRoot}
      ${builtins.readFile ./scripts/agent-sandbox}
    '';
  };
in
{
  environment.systemPackages = [
    sandboxFrontend
  ];

  systemd.tmpfiles.rules = [
    "d ${sandboxRoot} 0711 root root -"
    "d ${sandboxRoot}/by-uid 0711 root root -"
  ];

  security.sudo-rs.extraRules = [
    {
      groups = [ "server-users" ];
      runAs = "root:root";
      commands = [
        {
          command = ''${homeHelper}/bin/agent-sandbox-home ""'';
          options = [
            "NOPASSWD"
            "NOSETENV"
          ];
        }
      ];
    }
  ];

  assertions = [
    {
      assertion = builtins.hasAttr sandboxRoot config.fileSystems;
      message = "agent-sandbox requires ${sandboxRoot} to be a configured filesystem";
    }
  ];
}
