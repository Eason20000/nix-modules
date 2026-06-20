{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.hardware.zhaoxin;
in
{
  options.my.nixos.hardware.zhaoxin = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_6_6;

    boot.initrd.kernelModules = [
      "zx_core"
      "zx"
    ];
    boot.extraModulePackages = with config.boot.kernelPackages; [ zhaoxin ];

    boot.extraModprobeConfig = ''
      options zx_core zx_freezable_patch=2 zx_hotplug_polling_enable=1 zx_vesa_tempbuffer_enable=1 zx_recovery_enable=1 zx_pwm_mode=2 zx_force_3dblt=1
    '';

    hardware.graphics.extraPackages = [ pkgs.zhaoxin-userspace-driver ];
  };

}
