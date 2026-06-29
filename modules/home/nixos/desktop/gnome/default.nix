{ lib, pkgs, ... }:

let
  wallpaper = pkgs.fetchurl {
    url = "https://i.pximg.net/img-original/img/2020/08/31/22/44/30/84070482_p0.jpg";
    curlOpts = "--referer https://www.pixiv.net/";
    hash = "sha256-Gr5vdddBZX9qUDcZcpchCFjJ69ZR/Au61qeYSrHbUB0=";
  };

in
{
  imports = [
    ./extensions.nix
    ./ghostty.nix
  ];

  programs.gnome-shell.enable = true;

  home.packages = with pkgs; [
    piper
    amberol
    kooha
    gnome-sound-recorder
  ];

  dconf.settings = {

    "org/gnome/desktop/a11y".always-show-universal-access-status = true;

    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaper}";
      picture-uri-dark = "file://${wallpaper}";
    };

    "org/gnome/desktop/input-sources" = {
      per-window = true;
      sources = [
        (lib.gvariant.mkTuple [
          "xkb"
          "us"
        ])
        (lib.gvariant.mkTuple [
          "ibus"
          "rime"
        ])
      ];
    };

    "org/gnome/desktop/media-handling" = {
      automount = false;
      automount-open = false;
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      delay = lib.gvariant.mkUint32 250;
      repeat-interval = lib.gvariant.mkUint32 32;
    };

    "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";

    "org/gnome/desktop/input-sources".xkb-options = [
      "caps:ctrl_shifted_capslock"
    ];

    "org/gnome/desktop/interface".show-battery-percentage = true;

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      resize-with-right-button = true;
      titlebar-font = "Sans Bold 11";
    };

    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
        "kms-modifiers"
        "variable-refresh-rate"
        "xwayland-native-scaling"
      ];
      workspaces-only-on-primary = false;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = true;
      night-light-temperature = lib.gvariant.mkUint32 4500;
    };

    "org/gnome/settings-daemon/plugins/housekeeping".donation-reminder-enabled =
      false;

    "org/gnome/shell/app-switcher".current-workspace-only = true;

    "org/gnome/system/location".enabled = true;

    "org/gnome/nautilus/list-view" = {
      default-column-order = [
        "name"
        "detailed_type"
        "size"
        "type"
        "owner"
        "group"
        "permissions"
        "date_modified"
        "date_accessed"
        "date_created"
        "recency"
      ];
      default-visible-columns = [
        "name"
        "detailed_type"
        "size"
        "date_modified"
      ];
      use-tree-view = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-create-link = true;
      show-delete-permanently = true;
    };

    "org/gnome/TextEditor" = {
      discover-settings = false;
      highlight-current-line = true;
      indent-style = "space";
      restore-session = false;
      show-line-numbers = true;
      show-map = true;
      show-right-margin = true;
      tab-width = lib.gvariant.mkUint32 2;
    };

    "org/gnome/file-roller/ui".view-sidebar = true;

  };

}
