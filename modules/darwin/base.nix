{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.my.darwin.base;

in
{
  options.my.darwin.base = {
    hostname = lib.mkOption { type = lib.types.str; };
    stateVersion = lib.mkOption { type = lib.types.int; };
  };

  config = {
    networking.hostName = cfg.hostname;
    system.stateVersion = cfg.stateVersion;
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [ "https://nix-community.cachix.org" ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    nix.optimise.automatic = true;

    nixpkgs.hostPlatform = "aarch64-darwin";

    nix.gc = {
      automatic = true;
      interval = {
        Hour = 0;
        Minute = 0;
        Weekday = 0;
      };
      options = "--delete-older-than 7d";
    };

    environment.systemPackages = with pkgs; [
      git
      home-manager
    ];

    fonts.packages = with pkgs; [ nerd-fonts.fira-code ];

    environment.enableAllTerminfo = true;

    nixpkgs.config.allowUnfree = true;

  };

}
