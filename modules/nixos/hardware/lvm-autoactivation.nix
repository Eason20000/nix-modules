{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.hardware.lvmAutoactivation;

  activate = pkgs.writeShellScript "lvm-autoactivation" ''
    set -eu

    if [ "$(${pkgs.lvm2}/bin/lvm dumpconfig --type full --valuesonly global/event_activation 2>/dev/null)" != 1 ]; then
      exit 0
    fi

    exec ${pkgs.lvm2}/bin/lvm vgchange -aay --autoactivation event
  '';

in
{
  options.my.nixos.hardware.lvmAutoactivation = {
    enable = lib.mkEnableOption "" // {
      default = true;
    };
  };

  config = lib.mkIf (cfg.enable && config.services.lvm.enable) {
    systemd.services.lvm-autoactivation = {
      description = "Complete LVM autoactivation after initrd switch-root";
      wantedBy = [ "local-fs-pre.target" ];
      before = [ "local-fs-pre.target" ];
      after = [
        "systemd-remount-fs.service"
        "systemd-udevd.service"
      ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = [
          "-${config.systemd.package}/bin/udevadm settle --timeout=30"
        ];
        ExecStart = activate;
      };
    };
  };
}
