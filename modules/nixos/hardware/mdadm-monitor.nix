{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.hardware.mdadmMonitor;

in
{
  options.my.nixos.hardware.mdadmMonitor = {
    enable = lib.mkEnableOption "" // {
      default = true;
    };

    program = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.coreutils}/bin/true";
      example = "/run/current-system/sw/bin/mdadm-notify";
      description = ''
        Program that mdadm's monitor runs for array events (the
        `PROGRAM` directive in `mdadm.conf`). The default discards
        events; set a script if alerts should be delivered.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && config.boot.swraid.enable) {
    boot.swraid.mdadmConf = lib.mkDefault "PROGRAM ${cfg.program}";
  };
}
