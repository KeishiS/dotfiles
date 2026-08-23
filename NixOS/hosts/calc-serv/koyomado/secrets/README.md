# koyomado の secret

`.sops.yaml` の `^hosts/calc-serv/.*` 規則(yubikey + nixos-sandi-calc-serv の age 鍵)で暗号化する。
flake 評価に含めるため、暗号化済みファイルは Git 管理に入れる。

## admin-emails.enc

管理者として扱うメールアドレスを 1 行 1 件で書いた平文を、binary 形式で暗号化したもの。
`services.koyomado.adminEmailsFile` に渡り、`koyomado.service` には systemd credential として届く。

```sh
cd NixOS
printf 'nobuta05@gmail.com\n' > hosts/calc-serv/koyomado/secrets/admin-emails
sops --encrypt --input-type binary --output-type binary \
  hosts/calc-serv/koyomado/secrets/admin-emails \
  > hosts/calc-serv/koyomado/secrets/admin-emails.enc
rm hosts/calc-serv/koyomado/secrets/admin-emails   # または clean-secrets
git add hosts/calc-serv/koyomado/secrets/admin-emails.enc
```

変更時も同じ手順で作り直す。`restartUnits` により反映時に `koyomado.service` が再起動する。
