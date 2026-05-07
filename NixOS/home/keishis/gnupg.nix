{ pkgs, ... }:
{
  home.file.".gnupg/scdaemon.conf".text = ''
    disable-ccid
    pcsc-driver ${pkgs.pcsclite.lib}/lib/libpcsclite.so.1
  '';
}
