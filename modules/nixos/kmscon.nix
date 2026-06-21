{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.nixos.kmscon;

  font-size = builtins.floor (11.0 / 72 * cfg.dpi + 0.5);

in
{
  options.my.nixos.kmscon = {
    enable = lib.mkEnableOption "" // {
      default = true;
    };
    mode = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "1024x768";
    };
    dpi = lib.mkOption {
      type = lib.types.int;
      default = 96;
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = [ pkgs.unifont ];

    services.kmscon = {
      enable = true;
      config = {
        term = "xterm-direct";
        hwaccel = true;
        font-name = "Unifont";
        font-size = font-size;
        palette = "custom";
        palette-black = "36,31,49";
        palette-red = "192,28,40";
        palette-green = "46,194,126";
        palette-yellow = "245,194,17";
        palette-blue = "30,120,228";
        palette-magenta = "152,65,187";
        palette-cyan = "10,185,220";
        palette-light-grey = "192,191,188";
        palette-dark-grey = "94,92,100";
        palette-light-red = "237,51,59";
        palette-light-green = "87,227,137";
        palette-light-yellow = "248,228,92";
        palette-light-blue = "81,161,255";
        palette-light-magenta = "192,97,203";
        palette-light-cyan = "79,210,253";
        palette-white = "246,245,244";
        palette-foreground = "246,245,244";
        palette-background = "28,28,31";
        xkb-options = "caps:ctrl_shifted_capslock";
        xkb-repeat-delay = 250;
        xkb-repeat-rate = 32;
        multi-monitor = "largest";
        dpms-timeout = 300;
      }
      // lib.optionalAttrs (cfg.mode != null) { mode = cfg.mode; };
    };

  };

}
