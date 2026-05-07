# home-srv PostgreSQL

## 復号化テスト

YubiKey recipient で暗号化しているため identity file を用いて以下のように復号化できる．

```
rage -d \
    -i /path/to/<yubikey-identity>.txt
    /path/to/<encrypted file>.dump.zst.age \
    | zstd -d \
    > /tmp/<decrypted file>.dump
```
