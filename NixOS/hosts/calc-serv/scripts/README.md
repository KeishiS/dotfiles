# agent-sandbox

## ファイルのマウント

ホスト側のファイルを隔離環境内の指定した絶対パスへ読み取り専用で公開する場合は、
`--mount-file`に両方のパスを指定する。このオプションは複数回指定できる。

```console
agent-sandbox \
  --mount-file ~/.config/example/config.toml "/sandbox/by-uid/$(id -u)/.config/example/config.toml"
```

## ホーム設定の適用

隔離環境のホームは、ホストと同じ`/sandbox/by-uid/<uid>`です。
Home Managerの適用には`agent-home-switch`を使います。
初回適用と旧環境からの移行は[ホーム設定の説明](../../../home/agent/README.md)を参照してください。

## 適用処理の検証

リポジトリのルートで次を実行します。Bash、Bubblewrap、coreutils、flockが必要です。
Nix環境の一時ホームと代替コマンドを使い、実際のホームやGC rootは変更しません。

```console
bash NixOS/hosts/calc-serv/scripts/tests/agent-home-switch.sh
```
