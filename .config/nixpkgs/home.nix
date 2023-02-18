{pkgs, ...}:

{
    programs.home-manager.enable = true;
    home.username = "nobuta05";
    home.homeDirectory = "/home/nobuta05";
    home.stateVersion = "22.11";

    home.packages = with pkgs; [
        file
        gnome.gnome-sound-recorder
        patchelf
    ];
    
    programs.starship = {
        enable = true;
    };
}
