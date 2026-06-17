{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.my.darwin.homebrew;

in
{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  options.my.darwin.homebrew = {
    enable = lib.mkEnableOption "" // {
      default = true;
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = cfg.user;
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        };
        mutableTaps = false;
      };

      homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
      homebrew.enable = true;
    })

    (lib.mkIf (cfg.enable && config.my.darwin.desktop.enable or false) {
      homebrew.casks = [
        "blackhole-2ch"
        "neteasemusic"
        "xquartz"
        "linearmouse"
        "hiddenbar"
        "clash-verge-rev"
        "qq"
        "wechat"
      ];
    })
  ];
}
