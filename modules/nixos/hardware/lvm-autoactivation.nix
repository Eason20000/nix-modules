{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.hardware.lvmAutoactivation;

  # lvm2's udev rule starts a transient `lvm-activate-<VG>.service` with
  # `systemd-run --no-block`. That unit is not part of the initrd switch-root
  # transaction, so `initrd-cleanup`'s isolate stops it while it is still
  # activating and leaves /run/lvm/vgs_online/<VG> behind; the stage-2 pvscan
  # then skips the VG and its mounts time out. Make the unit declare the
  # ordering itself:
  #
  #   Type=oneshot         the start job completes when vgchange exits. This
  #                        is required: systemd-run defaults to Type=exec,
  #                        whose start job is done at execve().
  #   IgnoreOnIsolate=yes  initrd-cleanup's isolate must not stop the unit
  #                        (systemd's shall_stop_on_isolate() honours it).
  #   Before=...           initrd.target and the switch-root target wait for
  #                        the start job, so switch-root cannot outrun LVM.
  #
  # Only the initrd rule is patched; initrd-switch-root.target does not exist
  # in stage 2, and stage 2 has no isolate that kills these units.
  lvmRules = pkgs.runCommand "lvm-activate-rules-initrd" { } ''
    install -D -m0644 \
      ${config.services.lvm.package}/lib/udev/rules.d/69-dm-lvm.rules \
      $out/etc/udev/rules.d/69-dm-lvm.rules
    substituteInPlace $out/etc/udev/rules.d/69-dm-lvm.rules \
      --replace-fail \
        '--property DefaultDependencies=no' \
        '--service-type=oneshot --property DefaultDependencies=no --property IgnoreOnIsolate=yes --property Before=initrd.target --property Before=initrd-switch-root.target'
  '';

in
{
  options.my.nixos.hardware.lvmAutoactivation = {
    enable =
      lib.mkEnableOption "ordering of udev-started LVM activation against initrd switch-root"
      // {
        default = true;
      };
  };

  config = lib.mkIf (cfg.enable && config.boot.initrd.services.lvm.enable) {
    # udevRulesFor() copies every rule file with `cat > $out/$(basename)`,
    # so appending our package makes this copy override lvm2's copy of
    # 69-dm-lvm.rules.
    boot.initrd.services.udev.packages = lib.mkAfter [ lvmRules ];
  };
}
