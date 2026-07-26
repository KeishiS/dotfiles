# agent-sandbox

## ファイルのマウント

ホスト側のファイルを隔離環境内の指定した絶対パスへ読み取り専用で公開する場合は、
`--mount-file`に両方のパスを指定する。このオプションは複数回指定できる。

```console
agent-sandbox \
  --mount-file ~/.config/example/config.toml /home/agent/.config/example/config.toml
```
