{ config, ... }:
let
  # Ollama はこのホスト(calc-serv)の GPU で動かしている。scraper は OpenAI 互換 API(/v1)を使う。
  ollamaBaseUrl = "http://127.0.0.1:12001/v1";
in
{
  # 管理者メールアドレス(1 行 1 件)。koyomado.service には systemd credential として渡るため root 所有でよい。
  sops.secrets.koyomado-admin-emails = {
    format = "binary";
    sopsFile = ./secrets/admin-emails.enc;
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = [ "koyomado.service" ];
  };

  services.koyomado = {
    enable = true;
    baseUrl = "https://koyomado.com";

    # TLS は n100 の nginx(koyomado.com の A record が指す固定 IP)で終端し、LAN 越しにここへ転送する
    # (lenovo の marginalis と同じ方式)。backend は X-Forwarded-* を使わないため nginx 側の追加設定は不要。
    listenAddress = "0.0.0.0:8080";
    openFirewall = true;

    # PostgreSQL は同一ホストに立てる(socket + peer 認証、パスワード不要)。
    database.createLocally = true;

    cognito = {
      region = "ap-northeast-1";
      # infra/terraform/auth の `terraform output client_id` の値。公開 client の ID で秘密ではない。
      clientId = "REPLACE_WITH_TERRAFORM_OUTPUT_client_id";
    };

    adminEmailsFile = config.sops.secrets.koyomado-admin-emails.path;

    # 定期収集: 1 日 1 回、一覧ページを scraper で抽出して候補表へ取り込む。候補は /admin/candidates で承認する。
    scraper = {
      enable = true;
      interval = "1d";
      llm.baseUrl = ollamaBaseUrl;
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
