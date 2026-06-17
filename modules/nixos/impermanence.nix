{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.my.nixos.impermanence;

in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options.my.nixos.impermanence = {
    enable = lib.mkEnableOption "";
    extraDirectories = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
    };
    extraFiles = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.persistence."/nix/persist/nixos" = {
      hideMounts = true;
      allowTrash = true;
      directories = [
        "/var/tmp"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/etc/NetworkManager/system-connections"
        {
          directory = "/etc/secrets";
          mode = "0700";
        }
        {
          directory = "/var/lib/private";
          mode = "0700";
        }
      ]
      ++ cfg.extraDirectories;
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ]
      ++ cfg.extraFiles;
    };

    users.mutableUsers = true;

    programs.fuse.userAllowOther = true;

    systemd.tmpfiles.rules = [ "d /nix/persist/ 1777 root root" ];

  };

}
