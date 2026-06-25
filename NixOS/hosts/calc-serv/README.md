# calc-serv

## Storage

データ領域は、NFSで公開するためのmulti-device btrfsとして構成する。

- Data profile: `raid1c3`
- Metadata profile: `raid1c3`
- Exportするsubvolume: `/storage`, `/users`
- 定期scrub: `/storage` に対して `services.btrfs.autoScrub`

`raid1c3` は各blockを3つ保持するため、最大2台までのdisk故障に耐えることを意図している。
故障したdiskは速やかに交換し、degraded状態での長期運用は避ける。

## Kanidmユーザ追加手順

Kanidmの通常管理は `idm_admin` で行う。
`admin` はdomainやsystem寄りの管理用であり、ユーザ・groupの通常管理では基本的に使わない。

初回またはsessionが切れている場合はloginする。

```bash
kanidm login --name idm_admin
```

### 0. 初回のみlogin許可groupをPOSIX groupにする

`server-users` はLinux login、Vaultwarden login、Nextcloud loginを許可するためのgroupとして使う。
初回だけPOSIX groupとして有効化する。
すでに有効化済みなら再実行は不要。

```bash
kanidm group posix set --name idm_admin server-users
# 以下で設定を確認
kanidm group posix show --name idm_admin server-users
```

### 1. personを作成する

`<USER>` はlogin名、`<DISPLAY_NAME>` は表示名に置き換える。

```bash
kanidm person create --name idm_admin <USER> "<DISPLAY_NAME>"
# mail addressの登録
kanidm person update --name idm_admin <USER> --mail <USER@example.com>

# posix/vaultwarden/nextcloudの利用権限を付与
kanidm group add-members --name idm_admin server-users <USER>
# グループ設定の確認
kanidm group get --name idm_admin server-users
kanidm group posix show --name idm_admin server-users

# shell情報の設定(uidを自動振り分けする場合)
kanidm person posix set --name idm_admin <USER> --shell /run/current-system/sw/bin/bash
# shell情報の設定(uidを指定する場合)
kanidm person posix set --name idm_admin <USER> --shell /run/current-system/sw/bin/bash --gidnumber <GID>
# posix関連情報の確認
kanidm person posix show --name idm_admin <USER>

# credentialsの設定
## 公開鍵の登録
kanidm person ssh add-publickey --name idm_admin <USER> <KEY_NAME> "<PUBLIC_KEY>"
## 登録済み鍵の確認
kanidm person ssh list-publickeys --name idm_admin <USER>

# kanidmのユーザ・グループ管理権限を付与する場合, idm_admins へ所属させる
kanidm group add-members --name idm_admin idm_admins <USER>
# web UIを表示させる場合
kanidm group add-members --name idm_admin idm_ui_enable_experimental_features <USER>
```

### client側での設定確認

```bash
# NSSで見えるかの確認
getent passwd <USER>
getent group server-users

# SSH鍵解決の確認
/run/wrappers/bin/kanidm_ssh_authorizedkeys <USER>
```

### 5. credentialを設定する

初回passwordやpasskeyなどのcredentialは、Kanidm Web UIまたはKanidm CLIで設定する。
`kanidm-provision` はpersonやgroupの作成には使えるが、credentialやSSH public keyの登録までは扱わない。

### 6. client側で確認する

loginできない場合は、以下を確認する。

```bash
journalctl -u kanidm-unixd -b
journalctl -u kanidm-unixd-tasks -b
kanidm person posix show --name idm_admin <USER>
kanidm group get --name idm_admin server-users
kanidm group posix show --name idm_admin server-users
```

### Vaultwarden OAuth2連携

VaultwardenのloginをKanidmに寄せるため、Kanidm側でOAuth2 / OpenID Connect clientを作成する。
Vaultwarden側ではSSOを有効にするが、移行中に閉め出されないよう `SSO_ONLY=false` にしている。

Kanidm側の設定:

```text
client id: vaultwarden
display name: Vaultwarden
landing URL: https://key.sandi05.com/#/sso
redirect URL: https://key.sandi05.com/identity/connect/oidc-signin
discovery URL: https://id.sandi05.com/oauth2/openid/vaultwarden/.well-known/openid-configuration
issuer URL: https://id.sandi05.com/oauth2/openid/vaultwarden
```

loginを許可するユーザは `server-users` に追加する。
Linux login、Vaultwarden、Nextcloudの許可groupを共通化しているため、Vaultwarden専用groupは使わない。

Kanidm側のclient secretを確認する。

```bash
kanidm system oauth2 show-basic-secret --name idm_admin vaultwarden
```

Vaultwarden側の `hosts/lenovo/secrets/vw.env.enc` には、既存のSMTP secretなどに加えて次の値を入れる。
client secretはNix storeに置かない。

```env
SSO_CLIENT_SECRET=<KANIDM_VAULTWARDEN_CLIENT_SECRET>
```

Vaultwarden側の主な設定:

```text
SSO_ENABLED=true
SSO_ONLY=false
SSO_AUTHORITY=https://id.sandi05.com/oauth2/openid/vaultwarden
SSO_CLIENT_ID=vaultwarden
SSO_SCOPES="email profile"
SSO_PKCE=true
```

既存のVaultwardenユーザとKanidmユーザを対応させるには、両者のmail addressを一致させる。
`SSO_SIGNUPS_MATCH_EMAIL=true` により、mail addressが一致する既存ユーザはSSO login時に関連付けられる。

login確認は、Kanidmのapplications画面またはVaultwardenのSSO画面から行う。

```text
https://id.sandi05.com/ui/apps
https://key.sandi05.com/#/sso
```

VaultwardenのSSO画面で `SSO識別子` を求められた場合は、次を入力する。

```text
vaultwarden
```

Kanidm側ですでにlogin済みのbrowser sessionがある場合、ユーザ名・passwordの入力画面は省略される。
初回または要求される情報が変わった場合は、Kanidmのconsent画面で `email` と `email_verified` の提供確認が表示される。
別ユーザで確認したい場合は、Kanidmからlogoutするか、private windowまたは別browser profileを使う。

確認する。

```bash
kanidm system oauth2 get --name idm_admin vaultwarden
kanidm group get --name idm_admin server-users
journalctl -u vaultwarden -b
```

SSO loginで問題なく使えることを確認してから、必要であれば `SSO_ONLY=true` に変更する。

### Nextcloud OAuth2連携

NextcloudのloginをKanidmに寄せるため、Kanidm側でOAuth2 / OpenID Connect clientを作成する。
Nextcloud側は `user_oidc` appを使う。
Nextcloud本体は `hosts/calc-serv/nextcloud.nix` でcalc-serv上に配置する。
`/storage/nextcloud` はcalc-servから見るとlocal filesystemなので、NFS越しの権限問題を避けられる。
`storage.sandi05.com` はn100のnginxからcalc-servへ転送する。

Kanidm側の設定:

```text
client id: nextcloud
display name: Nextcloud
landing URL: https://storage.sandi05.com
redirect URL: https://storage.sandi05.com/apps/user_oidc/code
discovery URL: https://id.sandi05.com/oauth2/openid/nextcloud/.well-known/openid-configuration
issuer URL: https://id.sandi05.com/oauth2/openid/nextcloud
```

loginを許可するgroup:

```text
server-users
  Linux login、Vaultwarden login、Nextcloud loginを許可するユーザ
```

Nextcloud側のgroup制限は使わない。
`user_oidc` はgroup claimをid token内に期待するが、Kanidmの `groups_name` はこの用途では期待通りに扱えなかったため、
Nextcloud側では `groupProvisioning=false` と `restrictLoginToGroups=false` にしている。
login許可はKanidm側の `oauth2_rs_scope_map` で `server-users` に scopeを割り当てることで制御する。

Kanidm側のclient secretを確認する。

```bash
kanidm system oauth2 show-basic-secret --name idm_admin nextcloud
```

calc-serv側には次のsecretを置く。

```text
hosts/calc-serv/secrets/nextcloud-smtp-password.enc
  Resend API key

hosts/calc-serv/secrets/nextcloud-oidc-client-secret.enc
  kanidm system oauth2 show-basic-secret --name idm_admin nextcloud の出力
```

どちらもflake評価に含めるため、暗号化したうえでGit管理に入れる。

```bash
git add \
  NixOS/hosts/calc-serv/secrets/nextcloud-smtp-password.enc \
  NixOS/hosts/calc-serv/secrets/nextcloud-oidc-client-secret.enc
```

Nextcloud側では `user_oidc` appを有効化し、providerを作成する。
この設定は `nextcloud-kanidm-oidc.service` が自動実行する。
実行内容は概ね次の通り。

```bash
sudo -u nextcloud nextcloud-occ app:enable user_oidc
sudo -u nextcloud nextcloud-occ user_oidc:provider kanidm \
  --clientid="nextcloud" \
  --clientsecret-file="/run/secrets/nextcloud-oidc-client-secret" \
  --discoveryuri="https://id.sandi05.com/oauth2/openid/nextcloud/.well-known/openid-configuration" \
  --scope="openid email profile groups_name" \
  --mapping-groups="groups_name" \
  --group-provisioning=0 \
  --group-whitelist-regex="/^server-users$/" \
  --group-restrict-login-to-whitelist=0
```

loginを許可するユーザは `server-users` に追加する。
管理者として扱いたいユーザは、初回login後にNextcloud側で管理者権限を付与する。

```bash
kanidm group add-members --name idm_admin server-users <USER>
```

確認する。

```bash
kanidm system oauth2 get --name idm_admin nextcloud
kanidm group get --name idm_admin server-users
systemctl status nextcloud-setup
systemctl status nextcloud-kanidm-oidc
journalctl -u nextcloud-kanidm-oidc -b
sudo -u nextcloud nextcloud-occ status
sudo -u nextcloud nextcloud-occ app:list | grep -A 5 -B 5 user_oidc
sudo -u nextcloud nextcloud-occ user_oidc:provider kanidm --output=json_pretty
```

### Jellyfin

Jellyfinは `hosts/lenovo/jellyfin.nix` で有効化し、NFS上のmedia置き場として
`/storage/jellyfin/media` を使う。

公開URL:

```text
https://stream.sandi05.com
```

Jellyfin用の保存先はcalc-serv側で作成する。
NFS越しでも同じ所有者として扱えるよう、lenovoとcalc-servの両方で
`jellyfin` user/groupのUID/GIDを固定している。

```text
uid: 953
gid: 953
media directory: /storage/jellyfin/media
```

JellyfinのSSOは公式機能ではないため、現時点では採用しない。
login userや権限はJellyfinの管理画面で通常通り作成・管理する。

### Kanidm password recovery mail

Kanidmでpassword紛失時の再発行に対応するため、credential reset linkをmail送信できるようにする。
Kanidm本体は直接SMTP送信せず、DB内のmessage queueにmessageを積む。
送信は `kanidm-mail-sender` がmessage queueを処理してSMTP relayへ渡す。

想定経路:

```text
Kanidm
  -> message queue
  -> kanidm-mail-sender
  -> Resend SMTP
  -> user email
```

calc-servでは `kanidm-mail-sender` をsystemd serviceとして起動する。
接続情報は `hosts/calc-serv/secrets/kanidm-mail-sender.enc.toml` に置く。

Resend SMTPの想定値:

```text
host: smtp.resend.com
port: 587
username: resend
password: <Resend API key>
```

secretに入れるTOMLの例:

```toml
token = "<kanidm mail-sender service account token>"

instance_display_name = "Sandi Kanidm"
instance_url = "https://id.sandi05.com"

mail_from_address = "kanidm@sandi05.com"
mail_reply_to_address = "noreply@sandi05.com"

mail_relay = "smtp.resend.com"
mail_username = "resend"
mail_password = "<resend-api-key>"
```

初回に必要な作業:

- Kanidmに `mail-sender` service accountを作成する
- `mail-sender` を `idm_message_senders` groupへ追加する
- `mail-sender` 用のread-write API tokenを発行し、`sops-nix` でsecret管理する
- Resendで送信元domainまたは送信元addressを検証する
- `hosts/calc-serv/secrets/kanidm-mail-sender.enc.toml` を作成する
- flake評価に含めるため、暗号化済みの `kanidm-mail-sender.enc.toml` をGit管理に入れる
- 各personに `mail` attributeを設定する
- self-service recoveryを使う場合はdomain設定でaccount recoveryを有効化する

Kanidm側の準備command例:

```bash
kanidm service-account create --name idm_admin mail-sender "Mail Sender" idm_admins
kanidm group add-members --name idm_admin idm_message_senders mail-sender
kanidm service-account api-token generate --name idm_admin mail-sender "mail sender token" --readwrite
```

self-service recoveryとは別に、Resendへの送信経路だけを確認する場合:

```bash
sudo -u kanidm \
  /run/current-system/sw/bin/kanidm-mail-sender \
  -c /etc/kanidm/config \
  -m /run/secrets/kanidm-mail-sender \
  --test-email <MAIL_ADDRESS>
```

self-service recoveryを有効化する場合:

```bash
kanidm system domain set-allow-account-recovery true --name admin
```

ユーザへ手動でreset linkを送信する場合:

```bash
kanidm person credential send-reset-token --name idm_admin <USER>
```

mail送信を使わず、reset tokenを手動で渡す場合:

```bash
kanidm person credential create-reset-token --name idm_admin <USER>
```

注意点:

- Resendの利用条件、料金、制限を事前に確認する。
- Resend API keyとKanidm mail-sender tokenはNix storeに入れない。
- `mail-sender` service accountは `idm_message_senders` 以外の強いgroupへ入れない。
- 高権限ユーザのcredential resetには制限がある。
- reset tokenは既定で1時間、最大24時間まで。

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
