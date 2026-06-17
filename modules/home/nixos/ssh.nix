{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.home.ssh;

in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d /home/${config.home.username}/.ssh 700 - - -"
    ];
    my.home.impermanence.extraDirectories = [ ".ssh" ];
  };

}
