{ config, lib, ... }:

let
  cfg = config.my.darwin.desktop.systemDefaults;

in
{
  options.my.darwin.desktop.systemDefaults = {
    enable = lib.mkEnableOption "" // {
      default = config.my.darwin.desktop.enable or false;
    };
  };

  config = lib.mkIf cfg.enable {
    system.defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.75;
        dashboard-in-overlay = true;
        mineffect = "scale";
        minimize-to-application = true;
        mru-spaces = false;
        persistent-apps = [
          { app = "/System/Cryptexes/App/System/Applications/Safari.app"; }
          { app = "/System/Applications/Utilities/Terminal.app"; }
          { app = "/System/Applications/Launchpad.app"; }
        ];
        show-recents = false;
        persistent-others = [ ];
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 2;
        wvous-tr-corner = 1;
      };
      finder.FXPreferredViewStyle = "Nlsv";
    };

    system.startup.chime = false;

    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
      swapLeftCommandAndLeftAlt = true;
      swapLeftCtrlAndFn = true;
    };

    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
