{ lib, pkgs, ... }:

let
  extensionsList = with pkgs.gnomeExtensions; [
    appindicator
    caffeine
    dash-to-dock
    desktop-lyric
    removable-drive-menu
    clipboard-history
    gsconnect
    system-monitor
    windownavigator
    power-off-options
    middle-click-to-close-in-overview
    keep-pinned-apps-in-appgrid
    app-grid-wizard
    launch-new-instance
    alphabetical-app-grid
    just-perfection
    top-bar-organizer
  ];

in
{
  programs.gnome-shell.extensions = map (extension: {
    package = extension;
  }) extensionsList;

  dconf.settings = {

    "org/gnome/shell/extensions/appindicator" = {
      icon-opacity = 255;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dash-max-icon-size = 64;
      show-trash = false;
      show-mounts = false;
      click-action = "focus-minimize-or-previews";
      scroll-action = "cycle-windows";
      require-pressure-to-show = false;
      intellihide = false;
      hide-delay = 0.0;
      show-delay = 0.0;
    };

    "org/gnome/shell/extensions/desktop-lyric" = {
      minimize = true;
      show-progress = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      override-background-dynamically = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      style-dialogs = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      style-dash-to-dock = 1;
    };

    "org/gnome/shell/extensions/blur-my-shell/hacks-level" = {
      hacks-level = 0;
    };

    "org/gnome/shell/extensions/system-monitor" = {
      show-swap = false;
    };

    "org/gnome/shell/extensions/alphabetical-app-grid" = {
      folder-order-position = "start";
    };

    "org/gnome/shell/extensions/rounded-window-corners-reborn" = {
      border-width = 1;
      global-rounded-corner-settings = lib.gvariant.mkArray [
        (lib.gvariant.mkDictionaryEntry "padding" (
          lib.gvariant.mkVariant (
            lib.gvariant.mkArray [
              (lib.gvariant.mkDictionaryEntry "left" (lib.gvariant.mkUint32 2))
              (lib.gvariant.mkDictionaryEntry "right" (lib.gvariant.mkUint32 2))
              (lib.gvariant.mkDictionaryEntry "top" (lib.gvariant.mkUint32 2))
              (lib.gvariant.mkDictionaryEntry "bottom" (lib.gvariant.mkUint32 2))
            ]
          )
        ))
        (lib.gvariant.mkDictionaryEntry "keepRoundedCorners" (
          lib.gvariant.mkVariant (
            lib.gvariant.mkArray [
              (lib.gvariant.mkDictionaryEntry "maximized" false)
              (lib.gvariant.mkDictionaryEntry "fullscreen" false)
            ]
          )
        ))
        (lib.gvariant.mkDictionaryEntry "borderRadius" (
          lib.gvariant.mkVariant (lib.gvariant.mkUint32 12)
        ))
        (lib.gvariant.mkDictionaryEntry "smoothing" (lib.gvariant.mkVariant 0.0))
        (lib.gvariant.mkDictionaryEntry "borderColor" (
          lib.gvariant.mkVariant (
            lib.gvariant.mkTuple [
              1.0
              1.0
              1.0
              0.075
            ]
          )
        ))
        (lib.gvariant.mkDictionaryEntry "enabled" (lib.gvariant.mkVariant true))
      ];
      blacklist = [ "com.mojang.minecraft.java-edition" ];
    };

    "org/gnome/shell/extensions/just-perfection" = {
      support-notifier-type = 0;
      clock-menu-position = 1;
      clock-menu-position-offset = 20;
      notification-banner-position = 2;
    };

    "org/gnome/shell/extensions/app-grid-wizard" = {
      enabled = true;
    };

    "org/gnome/shell/extensions/power-off-options" = {
      show-hybrid-sleep = true;
    };

    "org/gnome/shell/extensions/top-bar-organizer" = {
      left-box-order = [
        "activities"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "desktop-lyric@tuberry"
      ];
      center-box-order = [ ];
      right-box-order = [
        "drive-menu"
        "Clipboard History Indicator"
        "keyboard"
        "screenRecording"
        "screenSharing"
        "dwellClick"
        "a11y"
        "quickSettings"
        "dateMenu"
      ];
    };

  };

}
