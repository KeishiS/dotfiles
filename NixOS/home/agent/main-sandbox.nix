{ pkgs, ... }:{
    imports = [
        ./agent-config
    ];
    home = {
        username = "agent";
        homeDirectory = "/home/agent";

        packages = with pkgs; [
            pnpm_11
            nodejs_26
        ];

        sessionPath = [
            "$HOME/.local/bin"
            "$HOME/.nix-profile/bin"
            "$HOME/.local/share/pnpm/bin"
        ];

        sessionVariables = {
            PNPM_HOME = "$HOME/.local/share/pnpm";
            PNPM_CONFIG_GLOBAL_BIN_DIR = "$HOME/.local/share/pnpm/bin";
        };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;

      historySize = 10000;
      historyFileSize = 100000;
      historyControl = [
        "ignoredups"   # 直前の履歴と同じコマンドは保存しない
        "erasedups"    # 履歴に同じコマンドがある場合は最新の1件のみ保存
      ];
      shellOptions = [
        "histappend"   # 履歴ファイルは追記保存
        "checkwinsize" # コマンド実行時にターミナルサイズを確認し、表示崩れを防止
        "globstar"     # ** による再帰的なパス展開を有効化
      ];

      initExtra = ''
        source $HOME/.profile

        source ${pkgs.blesh}/share/blesh/ble.sh
        bleopt complete_auto_complete=1 # 入力中に補完候補を表示
        bleopt complete_auto_delay=100  # 自動補完を表示するまでの待ち時間
        bleopt complete_menu_style=desc # 補完メニュを表示するスタイル

        export GH_TOKEN=$(cat $HOME/.config/gh/token)
      '';
    };
}
