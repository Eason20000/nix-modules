{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.llama-cpp;

in
{
  options.my.nixos.llama-cpp = {
    enable = lib.mkEnableOption "";
    preset = lib.mkOption {
      type = lib.types.str;
      default = "cuda";
      example = "rocm";
    };
    modelsPreset = lib.mkOption {
      type = lib.types.submodule { freeformType = lib.types.attrs; };
      default = { };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.modelsPreset != { }) {
      services.llama-cpp.settings.models-preset = builtins.toString (
        pkgs.writeText "models-preset.ini" (lib.generators.toINI { } cfg.modelsPreset)
      );
    })
    (lib.mkIf cfg.enable { services.llama-cpp.enable = true; })

    (lib.mkIf (cfg.enable && cfg.preset == "rocm") {
      services.llama-cpp.package = pkgs.llama-cpp-rocm;
      hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];
    })

    (lib.mkIf (cfg.enable && cfg.preset == "cuda") {
      services.llama-cpp.package = (pkgs.llama-cpp.override { cudaSupport = true; });
    })

  ];

}
