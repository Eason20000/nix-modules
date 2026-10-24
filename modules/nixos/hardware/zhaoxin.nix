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
    boot.initrd.kernelModules = [
      "zx_core"
      "zx"
    ];
    boot.extraModulePackages = with config.boot.kernelPackages; [ zhaoxin ];

    # Matches upstream etc/modprobe.d/zx_gfx.conf from the driver .deb.
    boot.extraModprobeConfig = ''
      options zx_core zx_freezable_patch=2 zx_hotplug_polling_enable=1 zx_vesa_tempbuffer_enable=1 zx_recovery_enable=1 zx_pwm_mode=2 zx_force_3dblt=1
    '';

    # Only the VA-API backend is shipped (see pkgs/zhaoxin/userspace.nix).
    # Display goes through KMS + the modesetting X driver, 3D through
    # Mesa llvmpipe. The vendor GL stack is intentionally not installed.
    hardware.graphics.extraPackages = [ pkgs.zhaoxin-userspace-driver ];

    environment.variables = {
      # VA-API: libva scans /run/opengl-driver/lib/dri/*_drv_video.so
      LIBVA_DRIVER_NAME = "zx";
    };
  };

}
