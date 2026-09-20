# Delta GUI

Delta 0.16.1 の Linux x86_64 版を Home Manager で導入します。nixpkgs の
`delta` は Git の差分表示ツールなので、ここでは `delta-gui` というパッケージ名を
使います。起動コマンドは公式と同じ `delta` です。

## アーカイブの配置と導入

[公式ページ](https://delta.dev/download)にサインインして Linux x86_64 版を取得し、
このディレクトリの `.local/delta-linux-x86_64.tar.gz` に配置します。
`.local/` は `.gitignore` で除外しており、アーカイブを Git に追加する必要はありません。

リポジトリのルートで、アーカイブを Nix store に登録します。

```sh
nix-store --add-fixed sha256 NixOS/home/keishis/delta/.local/delta-linux-x86_64.tar.gz
```

`package.nix` の `requireFile` は、この登録済みファイルをハッシュで照合します。
Git 管理対象外のファイルを flake のソースとして直接参照しないため、Git から取得した
設定でも同じ方法でビルドできます。別のマシンでビルドする場合も、そのマシンの
Nix store に登録してください。未参照の登録ファイルが GC で削除された場合は再登録します。

`../default.nix` には `./delta` を追加済みです。通常の Home Manager 設定にこの変更を
取り込んだ後、対象ユーザーのマシンで適用します。次のコマンドはリポジトリのルートで実行します。
Git ベースの flake は未追跡の設定ファイルを含めないため、新規の `.nix` ファイルなどは
先に Git の管理対象へ追加してください。`.local/` のアーカイブは追加しません。

```sh
home-manager switch --flake ./NixOS/home/keishis#keishis
delta
```

アプリケーションメニューにも Delta が登録されます。デスクトップファイルには
`delta://` の関連付け情報も含まれます。同名コマンドを持つ `pkgs.delta` と同時に
導入しないでください。

## NixOS 向けの補正

`autoPatchelfHook` で ELF 実行ファイルのローダーとライブラリ探索先を Nix store 内の
パスに変更します。公式アーカイブの同梱ライブラリを保持し、実行時に読み込まれる
Wayland、Vulkan、EGL のライブラリを追加します。文字入力で使う Compose テーブルの
場所は起動ラッパーで指定します。このパッケージの起動に `nix-ld` は不要です。

実機では NixOS 側の GPU ドライバーとデスクトップセッションが必要です。
Home Manager のパッケージだけでは GPU ドライバーを設定できません。

## 更新

Nix store 内のアプリケーションは書き換えられないため、更新は新しいアーカイブを
`.local/` に配置し、`package.nix` の `version` と `hash` を変更して行います。
ハッシュは次のコマンドで確認できます。

```sh
nix hash file --type sha256 NixOS/home/keishis/delta/.local/delta-linux-x86_64.tar.gz
```

再度 `nix-store --add-fixed` で登録し、Home Manager を適用します。
アプリ内の自動更新は検証対象外です。新しいバージョンで依存ライブラリが変わる場合は、
パッケージの再検証も必要です。

## 検証範囲

2026-09-20 に、既存の `../flake.lock` が固定する nixpkgs を使って検証しました。

- Delta 0.16.1 のパッケージビルドと `--version`、`--help` の実行
- Delta を含む既存 Home Manager 構成の評価
- デスクトップファイルの構文検査
- 仮想 X11 画面（Xvfb）でのウィンドウ生成と、Mesa llvmpipe による Vulkan 描画初期化
- 仮想 Wayland 環境（Weston 15.0.1 の headless backend）でのウィンドウ生成と描画フレームの送信
- 起動ラッパー追加後の Compose テーブル読み込みエラーの解消

GUI 検証には一時的な設定・データディレクトリとローカルの通信先を使い、
ログインやプロジェクト操作は行っていません。ソフトウェア描画時に同梱 `libunwind` の
警告が出ましたが、ウィンドウ生成後もプロセスが動作していることを確認しました。

Wayland 検証では `DISPLAY` を解除し、XWayland を起動せずに `WAYLAND_DISPLAY` を
指定しました。Mesa llvmpipe を使い、Wayland プロトコルのログで `Delta` ウィンドウの
作成、描画バッファーの送信、フレーム通知の受信を確認しました。仮想環境では
カーソルテーマが見つからない警告も出ています。

実機の Sway・Hyprland と GPU による描画、日本語入力、ブラウザーからの認証復帰、ログイン後の
エージェント操作は未確認です。Home Manager 設定の適用も行っていません。
