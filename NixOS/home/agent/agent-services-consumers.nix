let
  mkConsumer =
    {
      id,
      callbackUrls,
      callbackPort ? null,
      port,
      public,
      enabled ? true,
    }:
    rec {
      inherit
        callbackUrls
        callbackPort
        enabled
        id
        port
        public
        ;
      oauthClientId = "agent-services-${id}";
      hostname = "mcp.sandi05.com";
      basePath = "/${id}";
      endpoint = "https://${hostname}${basePath}/mcp";
      protectedResourceMetadata = "https://${hostname}/.well-known/oauth-protected-resource${basePath}/mcp";
      issuer = "https://id.sandi05.com/oauth2/openid/${oauthClientId}";
      scopes = [ "openid" ];
      auditComponent = "${oauthClientId}-vmcp";
    };

  consumers = {
    codex = mkConsumer {
      id = "codex";
      callbackUrls = [ "http://localhost:8765/callback" ];
      callbackPort = 8765;
      port = 4483;
      public = true;
    };

    claude-code = mkConsumer {
      id = "claude-code";
      callbackUrls = [ "http://localhost:8765/callback" ];
      callbackPort = 8765;
      port = 4484;
      public = true;
    };

    # ChatGPT assigns a connector-specific callback URL when the custom app is
    # created. Keep the consumer reserved but disabled until that exact URL is
    # known; accepting a wildcard or the legacy callback would weaken redirect
    # URI validation.
    chatgpt = mkConsumer {
      id = "chatgpt";
      callbackUrls = [ ];
      port = 4485;
      public = false;
      enabled = false;
    };
  };

  enabledConsumers = builtins.filter (consumer: consumer.enabled) (builtins.attrValues consumers);
  isUniqueBy =
    getValue:
    builtins.length (
      builtins.attrNames (
        builtins.listToAttrs (
          map (consumer: {
            name = toString (getValue consumer);
            value = true;
          }) enabledConsumers
        )
      )
    ) == builtins.length enabledConsumers;
  hasUsableCallback = consumer: consumer.callbackUrls != [ ];
  hasValidId = consumer: builtins.match "[a-z0-9]+(-[a-z0-9]+)*" consumer.id != null;
in
assert isUniqueBy (consumer: consumer.oauthClientId);
assert isUniqueBy (consumer: consumer.endpoint);
assert isUniqueBy (consumer: consumer.port);
assert builtins.all hasUsableCallback enabledConsumers;
assert builtins.all hasValidId (builtins.attrValues consumers);
consumers
