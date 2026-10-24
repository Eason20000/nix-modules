{
  lib,
  pkgs,
  config,
  ...
}:

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
      show-progress = true;
      online-lyrics = true;
      lyric-location = "${config.home.homeDirectory}/.lyrics";
      refresh-interval = lib.gvariant.mkUint32 20;
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

    "org/gnome/shell/extensions/just-perfection" = {
      support-notifier-type = 0;
      clock-menu-position = 1;
      clock-menu-position-offset = 20;
      notification-banner-position = 2;
    };

    "org/gnome/shell/extensions/app-grid-wizard" = {
      enabled = true;
      show-quick-settings = false;
      folder-chrome-apps = false;
    };

    "org/gnome/shell/extensions/power-off-options" = {
      show-hybrid-sleep = true;
      show-settings = false;
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
