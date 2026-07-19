{ pkgs, ... }:
let
  agent-tools-install = pkgs.writeShellApplication {
    name = "agent-tools-install";
    runtimeInputs = [
      pkgs.bash
      pkgs.cacert
      pkgs.coreutils
      pkgs.curl
      pkgs.nodejs
      pkgs.pnpm
    ];
    text = ''
      export PNPM_HOME="''${PNPM_HOME:-$HOME/.local/share/pnpm}"
      export PNPM_CONFIG_GLOBAL_BIN_DIR="$PNPM_HOME/bin"
      export SSL_CERT_FILE="''${SSL_CERT_FILE:-${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt}"
      mkdir -p "$PNPM_CONFIG_GLOBAL_BIN_DIR" "$HOME/.local/bin"

      echo "Installing or updating Codex with pnpm..."
      pnpm add --global @openai/codex@latest

      if command -v claude >/dev/null 2>&1; then
        echo "Claude Code is already installed: $(claude --version)"
      else
        echo "Installing Claude Code with the official native installer..."
        installer="$(mktemp)"
        trap 'rm -f "$installer"' EXIT
        curl \
          --fail \
          --show-error \
          --silent \
          --location \
          --proto '=https' \
          --tlsv1.2 \
          https://claude.ai/install.sh \
          --output "$installer"
        bash "$installer"
      fi

      echo
      echo "Installed agent tools:"
      codex --version
      claude --version
    '';
  };
in
{
  home.packages = [
    pkgs.nodejs
    pkgs.pnpm
    agent-tools-install
  ];
}
