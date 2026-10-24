{
  config,
  lib,
  pkgs,
  inputs,
  my,
  ...
}:

let
  cfg = config.my.nixos.buildMachine;

in
{
  options.my.nixos.buildMachine = {
    is = lib.mkEnableOption "";
    # Default: acts as client unless it IS the builder
    use = lib.mkEnableOption "" // {
      default = !cfg.is;
    };
    builderHost = lib.mkOption {
      type = lib.types.str;
      default =
        let
          builderInfo = my.lib.queryHosts inputs {
            pred = h: h.config.my.nixos.buildMachine.is or false;
            map = _: h: {
              host = h.config.my.nixos.base.publicHost or h.config.networking.hostName or null;
              port = builtins.toString (lib.head (h.config.my.nixos.ssh.ports or [ 22 ]));
            };
            first = true;
          };
        in
        if builderInfo != null && builderInfo.host != null then
          "${builderInfo.host}:${builderInfo.port}"
        else
          "";
    };
    sshKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
    builderAuthorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    publicHostKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.use && cfg.builderHost != "") {
      nix.distributedBuilds = true;
      nix.buildMachines = [
        (
          {
            hostName = cfg.builderHost;
            systems = [ "x86_64-linux" ];
            supportedFeatures = [ "big-parallel" ];
            maxJobs = 4;
            speedFactor = 1;
            sshUser = "nix-builder";
          }
          // lib.optionalAttrs (cfg.sshKeyFile != null) { sshKey = cfg.sshKeyFile; }
          // lib.optionalAttrs (cfg.publicHostKey != null) {
            publicHostKey = cfg.publicHostKey;
          }
        )
      ];
    })

    (lib.mkIf cfg.is {
      users.users.nix-builder = {
        isSystemUser = true;
        group = "nix-builder";
        openssh.authorizedKeys.keys = cfg.builderAuthorizedKeys;
        useDefaultShell = true;
      };
      users.groups.nix-builder = { };
      nix.settings.trusted-users = [ "nix-builder" ];
    })

    (lib.mkIf (cfg.use && cfg.sshKeyFile == null) {
      assertions = [
        {
          assertion = false;
          message = "my.nixos.buildMachine.sshKeyFile must be set when use = true";
        }
      ];
    })
  ];

}
