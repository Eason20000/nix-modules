{ config, lib, ... }:

let
  cfg = config.my.darwin.ssh;

in
{
  options.my.darwin.ssh = {
    enable = lib.mkEnableOption "" // {
      default = true;
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;
    services.openssh.extraConfig = cfg.extraConfig;
  };

}
