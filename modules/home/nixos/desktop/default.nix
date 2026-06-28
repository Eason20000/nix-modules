{
  pkgs,
  osConfig,
  inputs,
  lib,
  ...
}:

{
  imports = [
    ./obs.nix
    ./flatpak.nix
  ];

  home.packages = with pkgs; [
    firefox
    inputs.gamemaker-flake.packages.x86_64-linux.ide-lts-2026
    godotPackages_4_6.godot
    gimp3-with-plugins
    prismlauncher
    libreoffice
    wineWow64Packages.staging
    winetricks
    netease-cloud-music-gtk
    alsa-utils
    crosspipe
    waypipe
    xwayland-satellite
    moonlight-qt
  ];

  programs.lutris = {
    enable = true;
    extraPackages = with pkgs; [
      mangohud
      winetricks
      gamescope
    ];
    protonPackages = with pkgs; [
      proton-ge-bin
      dwproton-bin
    ];
    winePackages = [ pkgs.wineWow64Packages.full ];
  };

  my.home.impermanence.extraDirectories = [
    ".mozilla"
    ".cache/mozilla"
    ".local/share/PrismLauncher"
    ".wine"
    ".local/share/wineprefixes"
    ".local/share/GameMakerStudio2"
    ".config/GameMakerStudio2"
    ".local/share/netease-cloud-music-gtk4"
    ".local/share/lutris"
    ".config/lutris"
    "Games"
    ".config/Moonlight Game Streaming Project"
  ];

  dconf = {
    enable = true;
    settings = {
      "com/gitee/gmg137/NeteaseCloudMusicGtk4" = {
        music-rate = lib.gvariant.mkUint32 4;
        desktop-lyrics = true;
        exit-switch = true;
      };
    };
  };

}
