{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.ollama;

in
{
  options.my.nixos.ollama = {
    enable = lib.mkEnableOption "";
    preset = lib.mkOption {
      type = lib.types.str;
      default = "cuda";
      example = "rx7800xt";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.ollama = {
        enable = true;
        environmentVariables = {
          OLLAMA_ORIGINS = "*";
          HTTPS_PROXY = config.networking.proxy.default or null;
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.preset == "rx7800xt") {
      services.ollama = {
        package = pkgs.ollama-rocm;
        rocmOverrideGfx = "11.0.1";
      };
      hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];
    })

    (lib.mkIf (cfg.enable && cfg.preset == "cuda") {
      services.ollama.package = pkgs.ollama-cuda;
    })

  ];

}
