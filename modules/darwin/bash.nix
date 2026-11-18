{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.darwin.bash;

in
{
  options.my.darwin.bash = {
    enable = lib.mkEnableOption "" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # The interactive prompt and aliases come from the shared home-manager
    # module (`modules/home/base.nix`), so both NixOS and Darwin use the same
    # ones. This only provides the system-wide bash and its completions.
    programs.bash = {
      enable = true;
      completion.enable = true;
    };

    environment.shells = [ pkgs.bashInteractive ];
  };
}
