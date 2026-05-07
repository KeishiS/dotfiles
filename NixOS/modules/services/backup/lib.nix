{ lib }:
{
  ageRecipientArgs =
    recipients:
    lib.concatMapStringsSep " " (
      recipient: "-r ${lib.escapeShellArg recipient}"
    ) recipients;

  b2RequiredEnv = ''
    : "''${B2_APPLICATION_KEY_ID:?B2_APPLICATION_KEY_ID is required}"
    : "''${B2_APPLICATION_KEY:?B2_APPLICATION_KEY is required}"
  '';

  b2AccountInfoEnv = ''
    export B2_ACCOUNT_INFO="$STATE_DIRECTORY/b2-account-info"
  '';

  b2Upload =
    {
      bucket,
      source,
      destination,
    }:
    ''
      b2v4 file upload --no-progress \
        ${lib.escapeShellArg bucket} \
        ${source} \
        ${destination}
    '';
}
