{ lib, ... }:

{
  imports = [ ./system-defaults.nix ];

  options.my.darwin.desktop = {
    enable = lib.mkEnableOption "";
  };

}
