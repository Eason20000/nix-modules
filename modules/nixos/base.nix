{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.base;

in
{
  options.my.nixos.base = {
    hostname = lib.mkOption { type = lib.types.str; };
    stateVersion = lib.mkOption { type = lib.types.str; };
    primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    publicHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = {
    # Base NixOS settings
    networking.hostName = cfg.hostname;
    system.stateVersion = cfg.stateVersion;

    # Nix settings
    nix.settings = lib.mkMerge [
      (import ../../common/nix-substituters.nix)
      {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      }
    ];
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # - Sad but you have no choice
    nixpkgs.config.allowUnfree = true;

    # System essentials
    environment.systemPackages = with pkgs; [
      git
      home-manager
      ufiformat
      usbutils
      pciutils
    ];

    # Locale settings
    time.timeZone = "Asia/Shanghai";
    i18n = {
      defaultLocale = "zh_CN.UTF-8";
      extraLocales = [ "ja_JP.UTF-8/UTF-8" ];
    };

    # Some preferred services
    environment.enableAllTerminfo = true;
    networking.networkmanager.enable = true;
    services.power-profiles-daemon.enable = true;
    boot.initrd.systemd.enable = true;

  };

}
