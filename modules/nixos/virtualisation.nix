{ config, lib, ... }:

let
  cfg = config.my.nixos.virtualisation;

in
{
  options.my.nixos.virtualisation = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };

      networking.firewall.trustedInterfaces = [ "virbr0" ];

      my.nixos.impermanence.extraDirectories = [ "/var/lib/libvirt" ];

    })

    (lib.mkIf (cfg.enable && config.my.nixos.desktop.enable or false) {
      programs.virt-manager.enable = true;
    })
  ];

}
