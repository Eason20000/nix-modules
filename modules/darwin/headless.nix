{ config, lib, ... }:

let
  cfg = config.my.darwin.headless;

in
{
  options.my.darwin.headless = {
    enable = lib.mkEnableOption "" // {
      default = !config.my.darwin.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    power.sleep = {
      display = "never";
      computer = "never";
      harddisk = "never";
    };
  };

}
