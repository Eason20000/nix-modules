{
  config,
  lib,
  pkgs,
  inputs,
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
          allConfigs = inputs.self.nixosConfigurations or { };
          builderName = lib.findFirst (
            name: allConfigs.${name}.config.my.nixos.buildMachine.is or false
          ) null (builtins.attrNames allConfigs);
          builderPort = builtins.toString (
            if builderName != null then
              lib.head (allConfigs.${builderName}.config.my.nixos.ssh.ports or [ 22 ])
            else
              22
          );
          builderPublicHost =
            if builderName != null then
              allConfigs.${builderName}.config.my.nixos.base.publicHost or builderName
            else
              null;
        in
        if builderName != null && builderPublicHost != null then
          "${builderPublicHost}:${builderPort}"
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
