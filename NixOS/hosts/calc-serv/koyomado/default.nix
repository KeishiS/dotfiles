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
      interval = "2d";
      llm.baseUrl = "http://127.0.0.1:12001/v1";
      llm.model = "gemma4:12b-mxfp8";
      sources = [
        # 国立科学博物館(上野本館・筑波実験植物園・自然教育園の展示一覧)
        {
          id = "kahaku";
          url = "https://www.kahaku.go.jp/tenji/exhibitions.html";
          institutionName = "国立科学博物館";
          tags = [
            "国立科学博物館"
            "科博"
          ];
        }

        # 東京都現代美術館(展覧会)
        {
          id = "mot";
          url = "https://www.mot-art-museum.jp/exhibitions/";
          institutionName = "東京都現代美術館";
          tags = [
            "東京都現代美術館"
            "MOT"
          ];
        }

        # 国立天文台(イベント)
        {
          id = "naoj";
          url = "https://www.nao.ac.jp/news/events/";
          institutionName = "国立天文台";
          tags = [
            "国立天文台"
            "NAOJ"
          ];
        }

        # 国立天文台 4D2U ドームシアター
        {
          id = "naoj-theater";
          url = "https://prc.nao.ac.jp/cgi-bin/naoj/4d2u/entry.cgi";
          institutionName = "国立天文台 4D2Uドームシアター";
          tags = [
            "国立天文台"
            "NAOJ"
            "4D2Uドームシアター"
          ];
        }

        # JAMSTEC(イベント)
        {
          id = "jamstec";
          url = "https://www.jamstec.go.jp/j/pr/events/";
          institutionName = "海洋研究開発機構";
          tags = [
            "海洋研究開発機構"
            "JAMSTEC"
          ];
        }

        # 理化学研究所(イベント)
        {
          id = "riken";
          url = "https://www.riken.jp/pr/events/events/";
          institutionName = "理化学研究所";
          tags = [
            "理化学研究所"
            "理研"
          ];
        }

        # 自然科学研究機構(イベント)
        {
          id = "nins";
          url = "https://www.nins.jp/event/";
          institutionName = "自然科学研究機構";
          tags = [
            "自然科学研究機構"
            "NINS"
          ];
        }

        # 高エネルギー加速器研究機構 KEK(イベント)
        {
          id = "kek";
          url = "https://www.kek.jp/ja/event";
          institutionName = "高エネルギー加速器研究機構";
          tags = [
            "高エネルギー加速器研究機構"
            "KEK"
          ];
        }

        # JAXA 施設見学・イベント
        {
          id = "jaxa";
          url = "https://fanfun.jaxa.jp/event/visit/";
          institutionName = "JAXA";
          tags = [ "JAXA" ];
        }
      ];
    };
  };

  # scraperのLLM endpointは forwarding/ のsshトンネルが用意するため、その後に起動する。
  systemd.services.koyomado-scraper-extract = lib.mkIf config.services.koyomado.scraper.enable {
    after = [ "llm-ssh-forwarding.service" ];
    wants = [ "llm-ssh-forwarding.service" ];
  };
}
