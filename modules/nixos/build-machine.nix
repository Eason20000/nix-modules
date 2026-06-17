{ config, lib, pkgs, inputs, ... }:

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
          builderName = lib.findFirst (name:
            allConfigs.${name}.config.my.nixos.buildMachine.is or false
          ) null (builtins.attrNames allConfigs);
          builderPort = builtins.toString
            (if builderName != null then
              lib.head (allConfigs.${builderName}.config.my.nixos.ssh.ports or [ 22 ])
            else 22);
          builderPublicHost = if builderName != null then
            allConfigs.${builderName}.config.my.nixos.base.publicHost or builderName
          else null;
        in
        if builderName != null && builderPublicHost != null
        then "${builderPublicHost}:${builderPort}"
        else "";
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

  config =
    let
      # Conditionally add publicHostKey when set
      withHostKey = attrs: attrs // lib.optionalAttrs (cfg.publicHostKey != null) {
        inherit (cfg) publicHostKey;
      };
      # Conditionally add sops sshKey when secret is defined
      withSshKey = attrs: attrs // lib.optionalAttrs (config.sops.secrets ? "nix-builder.sshkey") {
        sshKey = config.sops.secrets."nix-builder.sshkey".path;
      };
    in
    lib.mkMerge [
    (lib.mkIf (cfg.use && cfg.builderHost != "") {
      nix.distributedBuilds = true;
      nix.buildMachines = [
        (withSshKey (withHostKey {
          hostName = cfg.builderHost;
          systems = [ "x86_64-linux" ];
          supportedFeatures = [ "big-parallel" ];
          maxJobs = 4;
          speedFactor = 1;
          sshUser = "nix-builder";
        }))
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
  ];

}
