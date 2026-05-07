{ pkgs, ... }:
{
  home.file.".gnupg/scdaemon.conf".text = ''
    disable-ccid
    pcsc-driver ${pkgs.pcsclite.out}/lib/libpcsclite.so.1
  '';
}
