{ config, ... }:
{
  # 管理者メールアドレスの一覧(1行1件)。systemd credentialとしてserviceへ渡るため、
  # Nix storeには現れない。所有者はrootのままでよい。
  sops.secrets.koyomado-admin-emails = {
    format = "binary";
    sopsFile = ./secrets/koyomado-admin-emails.enc;
    mode = "0400";
    restartUnits = [ "koyomado.service" ];
  };

  services.koyomado = {
    enable = true;

    # 公開URLはn100のnginxが終端するhttps origin。cookieのSecureとOrigin検査の基準になる。
    baseUrl = "https://koyomado.com";

    # TLS終端は同一ホストではなくn100にあるため、LAN側からの転送を受けられるaddressで待ち受ける。
    listenAddress = "0.0.0.0:8080";
    openFirewall = true;

    # 同一ホストにPostgreSQLを立て、socket + peer認証で接続する。
    # 版とバックアップはこのホストの責務になる。
    database.createLocally = true;

    # infra/terraform/auth の出力。client IDは秘密情報ではないが、apply後に実際の値へ差し替える。
    cognito = {
      region = "ap-northeast-1";
      clientId = "<REPLACE ME>";
    };

    adminEmailsFile = config.sops.secrets.koyomado-admin-emails.path;

    # 定期収集。抽出にはこのホストから到達できるOpenAI互換endpointを使う。
    # endpoint自体はこのリポジトリの管理外で、事前に起動しておく必要がある。
    scraper = {
      enable = true;
      interval = "1d";
      llm.baseUrl = "http://127.0.0.1:12001/v1";
      sources = [
        # 国立科学博物館(上野本館・筑波実験植物園・自然教育園の展示一覧)
        "https://www.kahaku.go.jp/tenji/exhibitions.html"
        # 東京都現代美術館(展覧会)
        "https://www.mot-art-museum.jp/exhibitions/"
        # 国立天文台(イベント)
        "https://www.nao.ac.jp/news/events/"
        # 国立天文台 4D2U ドームシアター
        "https://prc.nao.ac.jp/cgi-bin/naoj/4d2u/entry.cgi"
        # JAMSTEC(イベント)
        "https://www.jamstec.go.jp/j/pr/events/"
        # 理化学研究所(イベント)
        "https://www.riken.jp/pr/events/events/"
        # 自然科学研究機構(イベント)
        "https://www.nins.jp/event/"
        # 高エネルギー加速器研究機構 KEK(イベント)
        "https://www.kek.jp/ja/event"
        # JAXA 施設見学・イベント
        "https://fanfun.jaxa.jp/event/visit/"
      ];
    };
  };
}
