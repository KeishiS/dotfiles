{ config, lib, ... }:
{
  # 管理者メールアドレスの一覧(1行1件)。systemd credentialとしてserviceへ渡るため、
  # Nix storeには現れない。所有者はrootのままでよい。
  sops.secrets.koyomado-admin-emails = {
    format = "binary";
    sopsFile = ./secrets/admin-emails.enc;
    mode = "0400";
    restartUnits = [ "koyomado.service" ];
  };

  services.koyomado = {
    enable = true;
    baseUrl = "https://koyomado.com";
    listenAddress = "0.0.0.0:8080";
    openFirewall = true;
    # 同一ホストにPostgreSQLを立て、socket + peer認証で接続する。
    # 版とバックアップはこのホストの責務になる。
    database.createLocally = true;

    cognito = {
      region = "ap-northeast-1";
      clientId = "6u18otli855h13ihnd08oukvsv";
    };

    adminEmailsFile = config.sops.secrets.koyomado-admin-emails.path;

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

  # scraperのLLM endpointは forwarding/ のsshトンネルが用意するため、その後に起動する。
  systemd.services.koyomado-scraper = lib.mkIf config.services.koyomado.scraper.enable {
    after = [ "llm-ssh-forwarding.service" ];
    wants = [ "llm-ssh-forwarding.service" ];
  };
}
