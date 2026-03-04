{ config, pkgs, ... }:
let
  yaceConfig = (pkgs.formats.yaml { }).generate "config.yaml" {
    apiVersion = "v1alpha1";
    discovery = {
      jobs = [
        {
          type = "AWS/SQS";
          regions = [ "ap-northeast-1" ];
          searchTags = [
            {
              key = "Environment";
              value = "prod";
            }
          ];
          period = 300; # 5分間隔でメトリクスを収集
          length = 900; # 15分間隔でメトリクスを保持
          metrics = [
            {
              # 取得および処理が可能なメッセージ数
              name = "ApproximateNumberOfMessagesVisible";
              statistics = [ "Average" ];
            }
            {
              # 受信されたが，削除されていないまたは期限が切れていない（つまり処理中の）メッセージ数
              name = "ApproximateNumberOfMessagesNotVisible";
              statistics = [ "Average" ];
            }

            {
              # キューに正常に送信されたメッセージ数
              name = "NumberOfMessagesSent";
              statistics = [ "Sum" ];
            }
            {
              # キューから正常に削除されたメッセージ数
              name = "NumberOfMessagesDeleted";
              statistics = [ "Sum" ];
            }
            {
              # 空のキューへポーリング等をした回数
              name = "NumberOfEmptyReceives";
              statistics = [ "Sum" ];
            }
          ];
        }
        {
          type = "AWS/Lambda";
          regions = [ "ap-northeast-1" ];
          searchTags = [
            {
              key = "Environment";
              value = "prod";
            }
          ];
          period = 300; # 5分間隔でメトリクスを収集
          length = 900; # 15分間隔でメトリクスを保持
          metrics = [
            {
              name = "Invocations";
              statistics = [ "Sum" ];
            }
            {
              name = "Errors";
              statistics = [ "Sum" ];
            }
            {
              name = "Duration";
              statistics = [
                "Average"
                # "p95"
              ];
            }
            {
              name = "ConcurrentExecutions";
              statistics = [ "Maximum" ];
            }
          ];
        }
      ];
    };
  };
in
{
  environment.etc."yace/config.yaml".source = yaceConfig;

  sops.secrets.aws-yace = {
    format = "binary";
    sopsFile = ./secrets/aws-yace.enc;
    mode = "0400";
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.yace = {
    image = "quay.io/prometheuscommunity/yet-another-cloudwatch-exporter:latest";
    ports = [ "127.0.0.1:5000:5000" ];
    volumes = [
      "/etc/yace/config.yaml:/config.yml:ro"
    ];
    cmd = [
      "--config.file=/config.yml"
    ];
    environmentFiles = [
      config.sops.secrets.aws-yace.path
    ];
  };
}
