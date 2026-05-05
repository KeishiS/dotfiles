{ pkgs, ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [ "systemd" ];
    extraFlags = [
      "--collector.systemd.unit-include=^keylytix-[^@]+@[^.]+\.service$"
    ];
  };
  networking.firewall.allowedTCPPorts = [ 9100 ];

  #------------------------------------------------------
  # OpenTelemetry Collector
  #------------------------------------------------------

  users.users.opentelemetry-collector = {
    isSystemUser = true;
    group = "systemd-journal";
  };

  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    settings = {
      receivers.journald = {
        directory = "/var/log/journal";
        units = [
          "keylytix-graphql-gateway@*.service"
          "keylytix-auth-service@*.service"
          "keylytix-user-query-service@*.service"
          "keylytix-user-command-service@*.service"
        ];
      };

      processors.transform = {
        error_mode = "ignore";
        log_statements = [
          {
            context = "log";
            statements = [
              ''set(resource.attributes["service.name"], body["_SYSTEMD_UNIT"]) where body["_SYSTEMD_UNIT"] != nil''
              ''set(resource.attributes["host.name"], body["_HOSTNAME"]) where body["_HOSTNAME"] != nil''
              ''merge_maps(attributes, ParseJSON(body["MESSAGE"]), "upsert") where body["MESSAGE"] != nil''
              ''set(body, attributes["message"]) where attributes["message"] != nil''
              ''set(severity_text, attributes["level"]) where attributes["level"] != nil''
              ''set(time, Time(attributes["timestamp"], "2006-01-02T15:04:05Z07:00")) where attributes["timestamp"] != nil''
              ''set(attributes["raw"], body["MESSAGE"]) where body["MESSAGE"] != nil''
            ];
          }
        ];
      };
      processors.batch = { };

      exporters."otlphttp/loki" = {
        endpoint = "http://192.168.10.17:3100/otlp";
        tls.insecure = true;
      };
      exporters.debug.verbosity = "detailed";

      service.pipelines.logs = {
        receivers = [ "journald" ];
        processors = [
          "transform"
          "batch"
        ];
        exporters = [
          "otlphttp/loki"
          "debug"
        ];
      };
    };
  };
}
