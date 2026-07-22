{ consumer }:
let
  allowedTools = [
    "triliumnext_list_children_notes"
    "triliumnext_search_notes"
    "triliumnext_get_note"
    "triliumnext_resolve_note_id"
    "triliumnext_read_attributes"
    "triliumnext_create_note"
    "triliumnext_update_note"
    "triliumnext_manage_attributes"
  ];
  permitTool = tool: ''
    permit(
      principal,
      action == Action::"call_tool",
      resource == Tool::"${tool}"
    );
  '';
in
{
  name = "agent-services-${consumer.id}";
  groupRef = "agent-services";

  incomingAuth = {
    type = "oidc";
    oidc = {
      inherit (consumer) issuer;
      clientId = consumer.oauthClientId;
      audience = consumer.oauthClientId;
      resource = consumer.endpoint;
      # Split DNS resolves this pinned issuer to a private address. Do not use
      # this exception with an issuer that is not managed by this deployment.
      jwksAllowPrivateIp = true;
      inherit (consumer) scopes;
    };
    authz = {
      type = "cedar";
      policies = map permitTool allowedTools;
    };
  };

  outgoingAuth = {
    source = "inline";
    default.type = "unauthenticated";
  };

  aggregation = {
    conflictResolution = "prefix";
    conflictResolutionConfig.prefixFormat = "{workload}_";
  };

  operational = {
    timeouts = {
      default = "30s";
      perWorkload = {
        triliumnext = "30s";
        leantime = "30s";
      };
    };
    failureHandling = {
      healthCheckInterval = "30s";
      unhealthyThreshold = 3;
      partialFailureMode = "fail";
      circuitBreaker = {
        enabled = true;
        failureThreshold = 5;
        timeout = "60s";
      };
    };
  };

  audit = {
    component = consumer.auditComponent;
    eventTypes = [
      "mcp_initialize"
      "mcp_tool_call"
    ];
    includeRequestData = false;
    includeResponseData = false;
    maxDataSize = 0;
  };
}
