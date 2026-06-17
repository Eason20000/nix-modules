{ config, lib, pkgs, my, osConfig, ... }:

let
  cfg = config.my.home.base;

in
{
  options.my.home.base = {
    username = lib.mkOption { type = lib.types.str; };
    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = osConfig.users.users.${cfg.username}.home;
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = (my.lib.nixos osConfig "base").stateVersion or null;
    };
  };

  config = {
    home.username = cfg.username;
    home.homeDirectory = cfg.homeDirectory;
    home.stateVersion = cfg.stateVersion;

    home.packages = with pkgs; [
      bc
      tree
      just
      nixfmt
      fastfetch
      btop
    ];

    programs.bash.enable = true;

    programs.dircolors.enable = true;

  };

}
