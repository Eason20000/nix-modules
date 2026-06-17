{ config, lib, ... }:

let
  cfg = config.my.nixos.hardware.teac;

  rules = ''
    ACTION=="add", SUBSYSTEM=="block", ATTR{removable}=="1", ATTRS{idVendor}=="0644", ATTRS{idProduct}=="0000", ATTR{events_poll_msecs}="0"
  '';

in
{
  options.my.nixos.hardware.teac = {
    enable = lib.mkEnableOption "" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = rules;
    boot.initrd.services.udev.rules = rules;
  };
}
