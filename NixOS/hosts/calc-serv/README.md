# calc-serv

## Storage

データ領域は、NFSで公開するためのmulti-device btrfsとして構成する。

- Data profile: `raid1c3`
- Metadata profile: `raid1c3`
- Exportするsubvolume: `/storage`, `/users`
- 定期scrub: `/storage` に対して `services.btrfs.autoScrub`

`raid1c3` は各blockを3つ保持するため、最大2台までのdisk故障に耐えることを意図している。
故障したdiskは速やかに交換し、degraded状態での長期運用は避ける。

## disk故障時の交換手順

disk交換はdiskoではなく、btrfsの運用commandで行う。
`disk.nix` は初期構築と現在の期待構成を記録するためのものとして扱い、
既存poolに対して `disko --mode destroy,format,mount` は実行しない。

### 1. 故障diskを特定する

通知内容、SMART、btrfsのerror counterを確認する。

```bash
journalctl -u smartd -b
smartctl -x /dev/disk/by-id/<target-disk>
btrfs device stats -T /storage
btrfs filesystem show /storage
btrfs filesystem usage /storage
```

実機のserial、model、`disk.nix` の `dataDiskN` を突き合わせる。

```bash
lsblk -o NAME,PATH,SERIAL,MODEL,SIZE,WWN
readlink -f /dev/disk/by-id/<target-disk>
```

交換対象のserialと `dataDiskN` を作業前に控える。

### 2. 新diskを接続してpartitionを作成する

新diskの `by-id` を確認する。

```bash
ls -l /dev/disk/by-id/
lsblk -o NAME,PATH,SERIAL,MODEL,SIZE,WWN
```

新diskにGPTとdata partitionを作成する。
`NEW_DISK` は `/dev/disk/by-id/...` のdisk本体を指定し、`-part1` は付けない。
`sgdisk --zap-all` は指定diskのpartition情報を消すため、必ずserial確認後に実行する。

```bash
sgdisk --zap-all /dev/disk/by-id/<NEW_DISK> # 既存のpartition tableやGPT metadataを削除
sgdisk --new=1:0:0 --typecode=1:8300 --change-name=1:data /dev/disk/by-id/<NEW_DISK> # partition番号1を，開始位置0，終了位置0(実質全領域)で作り，それのtype codeを8300とする．GPT partition nameをdataにする
blockdev --rereadpt /dev/disk/by-id/<NEW_DISK> # このdiskのpartition tableを読み込み直すようkernelに通達
udevadm settle # udevの処理が完了するまで待つ
```

作成後、partition pathを確認する。

```bash
ls -l /dev/disk/by-id/<NEW_DISK>-part1
```

### 3. btrfs replaceを実行する

旧diskがまだ見えている場合:

```bash
btrfs replace start -f \
  /dev/disk/by-id/<OLD_DISK>-part1 \
  /dev/disk/by-id/<NEW_DISK>-part1 \
  /storage
```

旧diskが完全に消えている場合は、`btrfs filesystem show /storage` でmissingの `devid` を確認し、
device pathの代わりに `devid` を使う。

```bash
btrfs filesystem show /storage
btrfs replace start -f <devid> /dev/disk/by-id/<NEW_DISK>-part1 /storage
```

進捗を確認する。

```bash
btrfs replace status /storage
```

### 4. 完了後に確認する

replace完了後、poolとerror counterを確認する。

```bash
btrfs filesystem show /storage
btrfs device stats -T /storage
btrfs scrub start -B /storage
btrfs scrub status /storage
```

新diskが交換前より大きく、全容量を使いたい場合は、対象 `devid` を確認してresizeする。

```bash
btrfs filesystem show /storage
btrfs filesystem resize <devid>:max /storage
```

### 5. disk.nixを更新する

replace完了後、交換した `dataDiskN` の値を新しい `by-id` に変更する。
`dataDiskNPart = "${dataDiskN}-part1";` の形にしておけば、partition pathは自動で追従する。

例:

```nix
dataDisk2 = "/dev/disk/by-id/nvme-NEW_DISK_ID";
dataDisk2Part = "${dataDisk2}-part1";
```

NixOS設定として評価できるか確認する。

```bash
nix eval .#nixosConfigurations.nixos-sandi-calc-serv.config.disko.devices.disk.data4.content.partitions.data.content.extraArgs
```

最後に通常のNixOS設定を反映する。

```bash
nixos-rebuild switch --flake .#nixos-sandi-calc-serv
```

### 禁止事項

- 既存poolに対して `disko --mode destroy,format,mount` を実行しない。
- 故障diskを外すために `btrfs balance ... convert=single` のような冗長性を下げる操作をしない。
- `btrfs check --repair` を通常の交換手順として実行しない。
- `sgdisk`, `wipefs`, `btrfs replace -f` の対象diskをserial確認なしに指定しない。

## 将来案: Cloudflare経由のsmartdメール通知

disk故障の通知は、Cloudflare Email Serviceを送信用SMTPとして使い、
`smartd` からメール送信できるようにする。

注意点:

- Cloudflare Email Routingだけでは、受信と転送が主用途なので `smartd` の送信通知には不足する。
- 送信用途にはCloudflare Email Service / Email Sendingが必要。
- API tokenは `sops-nix` などでruntime secretとして渡す。Nix codeに直接書かない。

実装案:

```nix
programs.msmtp = {
  enable = true;
  setSendmail = true;

  defaults = {
    aliases = "/etc/aliases";
    tls = true;
  };

  accounts.default = {
    host = "smtp.mx.cloudflare.net";
    port = 465;
    tls_starttls = false;
    auth = true;
    user = "api_token";
    passwordeval = "cat /run/secrets/cloudflare-email-api-token";
    from = "smartd@example.com";
  };
};

services.smartd = {
  enable = true;

  notifications.mail = {
    enable = true;
    sender = "smartd@example.com";
    recipient = "you@example.com";
  };
};
```

通知経路:

```text
smartd -> sendmail wrapper -> msmtp -> Cloudflare Email Sending SMTP
```

有効化する前に、送信元domainでCloudflare Email Sendingを設定し、
権限を絞ったAPI tokenをsecretとして追加する。
