{ pkgs, ... }:

{
  home.packages = with pkgs; [
    firefox
    vlc-bin
    prismlauncher
    utm
    blender
    osu-lazer-bin
  ];

}
