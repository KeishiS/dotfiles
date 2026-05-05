{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mailNotify;

  enabledAccounts = lib.filterAttrs (_: account: account.enable) cfg.accounts;

  notifyScript = pkgs.writeShellApplication {
    name = "mail-notify";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      account="$1"
      address="$2"
      title="$3"

      exec notify-send \
        --app-name="mail-notify" \
        "$title" \
        "$account <$address>"
    '';
  };

  mkSecretName = name: "mail-notify-${name}";
  mkOAuth2SecretName = name: field: "mail-notify-${name}-oauth2-${field}";

  mkPasswordCommand =
    name: account:
    let
      secretName = mkSecretName name;
      clientIdSecretName = mkOAuth2SecretName name "client-id";
      clientSecretSecretName = mkOAuth2SecretName name "client-secret";
      refreshTokenSecretName = mkOAuth2SecretName name "refresh-token";
      tokenCommand = pkgs.writeShellApplication {
        name = "mail-notify-token-${name}";
        runtimeInputs = [
          pkgs.curl
          pkgs.jq
        ];
        text = ''
          set -euo pipefail

          client_id="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.${clientIdSecretName}.path})"
          client_secret="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.${clientSecretSecretName}.path})"
          refresh_token="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.${refreshTokenSecretName}.path})"

          response="$(${pkgs.curl}/bin/curl --silent --show-error --fail \
            --request POST \
            --data-urlencode "client_id=$client_id" \
            --data-urlencode "client_secret=$client_secret" \
            --data-urlencode "refresh_token=$refresh_token" \
            --data-urlencode "grant_type=refresh_token" \
            ${lib.escapeShellArg account.oauth2.tokenEndpoint})"

          access_token="$(printf '%s' "$response" | ${pkgs.jq}/bin/jq -er '.access_token')"
          printf '%s' "$access_token"
        '';
      };
    in
    if account.oauth2.enable then
      "${tokenCommand}/bin/mail-notify-token-${name}"
    else
      "${pkgs.coreutils}/bin/cat ${config.sops.secrets.${secretName}.path}";

  mkAccountConfig =
    name: account:
    let
      command =
        "${notifyScript}/bin/mail-notify "
        + "${lib.escapeShellArg account.displayName} "
        + "${lib.escapeShellArg account.email} "
        + "${lib.escapeShellArg account.notificationTitle}";
    in
    {
      configurations = [
        {
          host = account.host;
          port = account.port;
          tls = true;
          tlsOptions = {
            rejectUnauthorized = true;
            starttls = account.starttls;
          };
          idleLogoutTimeout = account.idleLogoutTimeout;
          enableIDCommand = account.enableIDCommand;
          username = account.username;
          alias = account.displayName;
          passwordCMD = mkPasswordCommand name account;
          xoAuth2 = account.oauth2.enable || account.xoAuth2;
          wait = account.wait;
          boxes = map (mailbox: {
            inherit mailbox;
            onNewMail = command;
            onNewMailPost = "SKIP";
          }) account.boxes;
        }
      ];
    };
in
{
  options.services.mailNotify = {
    enable = lib.mkEnableOption "desktop notifications for IMAP mailboxes";

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "error"
        "warn"
        "warning"
        "info"
        "debug"
      ];
      default = "warn";
      description = "Log level passed to goimapnotify.";
    };

    accounts = lib.mkOption {
      default = { };
      description = "Mail accounts monitored by goimapnotify.";
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, config, ... }:
          {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Whether to enable notifications for this account.";
              };

              displayName = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Label shown in desktop notifications.";
              };

              email = lib.mkOption {
                type = lib.types.str;
                description = "Email address shown in desktop notifications.";
              };

              host = lib.mkOption {
                type = lib.types.str;
                description = "IMAP host name.";
              };

              port = lib.mkOption {
                type = lib.types.port;
                default = 993;
                description = "IMAP port.";
              };

              username = lib.mkOption {
                type = lib.types.str;
                default = config.email;
                defaultText = lib.literalExpression "config.services.mailNotify.accounts.<name>.email";
                description = "IMAP login name.";
              };

              secretFile = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                description = "Encrypted password or static token file consumed by sops-nix for this account.";
              };

              boxes = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ "INBOX" ];
                description = "Mailboxes watched for new mail.";
              };

              notificationTitle = lib.mkOption {
                type = lib.types.str;
                default = "New mail";
                description = "Notification title shown for this account.";
              };

              starttls = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether to use STARTTLS instead of implicit TLS.";
              };

              idleLogoutTimeout = lib.mkOption {
                type = lib.types.ints.positive;
                default = 15;
                description = "Minutes between IDLE restarts.";
              };

              wait = lib.mkOption {
                type = lib.types.ints.unsigned;
                default = 1;
                description = "Seconds to wait before running the notification command.";
              };

              enableIDCommand = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether to enable the IMAP ID command.";
              };

              xoAuth2 = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether the secret file contains an XOAUTH2 token instead of a password.";
              };

              oauth2 = {
                enable = lib.mkEnableOption "OAuth2 token refresh for this account";

                tokenEndpoint = lib.mkOption {
                  type = lib.types.str;
                  default = "https://oauth2.googleapis.com/token";
                  description = "OAuth2 token endpoint used to exchange refresh tokens for access tokens.";
                };

                clientIdFile = lib.mkOption {
                  type = lib.types.nullOr lib.types.path;
                  default = null;
                  description = "Encrypted OAuth2 client ID file consumed by sops-nix.";
                };

                clientSecretFile = lib.mkOption {
                  type = lib.types.nullOr lib.types.path;
                  default = null;
                  description = "Encrypted OAuth2 client secret file consumed by sops-nix.";
                };

                refreshTokenFile = lib.mkOption {
                  type = lib.types.nullOr lib.types.path;
                  default = null;
                  description = "Encrypted OAuth2 refresh token file consumed by sops-nix.";
                };
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf (cfg.enable && enabledAccounts != { }) {
    assertions = lib.mapAttrsToList (
      name: account:
      let
        oauth2SecretsConfigured =
          account.oauth2.clientIdFile != null
          && account.oauth2.clientSecretFile != null
          && account.oauth2.refreshTokenFile != null;
      in
      {
        assertion = if account.oauth2.enable then oauth2SecretsConfigured else account.secretFile != null;
        message =
          if account.oauth2.enable then
            "services.mailNotify.accounts.${name}: oauth2.enable = true requires oauth2.clientIdFile, oauth2.clientSecretFile, and oauth2.refreshTokenFile."
          else
            "services.mailNotify.accounts.${name}: secretFile is required when oauth2.enable is false.";
      }
    ) enabledAccounts;

    home.packages = [
      pkgs.goimapnotify
    ];

    sops.secrets =
      lib.foldl'
        lib.recursiveUpdate
        { }
        (lib.mapAttrsToList (
          name: account:
          let
            oauth2SecretAttrs = lib.optionalAttrs account.oauth2.enable {
              ${mkOAuth2SecretName name "client-id"} = {
                format = "binary";
                sopsFile = account.oauth2.clientIdFile;
                mode = "0400";
              };

              ${mkOAuth2SecretName name "client-secret"} = {
                format = "binary";
                sopsFile = account.oauth2.clientSecretFile;
                mode = "0400";
              };

              ${mkOAuth2SecretName name "refresh-token"} = {
                format = "binary";
                sopsFile = account.oauth2.refreshTokenFile;
                mode = "0400";
              };
            };
          in
          lib.optionalAttrs (!account.oauth2.enable) {
            ${mkSecretName name} = {
              format = "binary";
              sopsFile = account.secretFile;
              mode = "0400";
            };
          }
          // oauth2SecretAttrs
        ) enabledAccounts);

    xdg.configFile = lib.mapAttrs' (
      name: account:
      lib.nameValuePair "goimapnotify/${name}.yaml" {
        text = builtins.toJSON (mkAccountConfig name account);
      }
    ) enabledAccounts;

    systemd.user.services = lib.mapAttrs' (
      name: _:
      lib.nameValuePair "goimapnotify-${name}" {
        Unit = {
          Description = "IMAP mail notification watcher for ${name}";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart =
            "${pkgs.goimapnotify}/bin/goimapnotify "
            + "-conf ${config.xdg.configHome}/goimapnotify/${name}.yaml "
            + "-log-level ${cfg.logLevel}";
          Restart = "always";
          RestartSec = 30;
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      }
    ) enabledAccounts;
  };
}
