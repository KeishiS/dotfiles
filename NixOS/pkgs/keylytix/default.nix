{ pkgs, ... }:
let
  token = builtins.getEnv "GITHUB_TOKEN";
in
{
  frontend = pkgs.fetchurl {
    url = "https://github.com/KeishiS/KeyLytix/releases/download/v0.1.0/dist.tar.gz";
    sha256 = "20ff3ca34778f399f5cc75193672580bec1a1706b80fdb1feb76794722b2669f";
    headers = {
      Authorization = "token ${token}";
      Accept = "application/octet-stream";
    };
  };
}
