{ ... }:
let
  jellyfinUid = 953;
  jellyfinGid = 953;
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.groups.jellyfin.gid = jellyfinGid;
  users.users.jellyfin.uid = jellyfinUid;
}
