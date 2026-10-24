{ inputs, pkgs, ... }:

let
  inherit (pkgs) requireFile;

  # Source .deb for Zhaoxin graphics driver (kernel + userspace).
  # Provide the vendor .deb through requireFile's configured search path.
  # sha256: 8fba2330241412c8195a953932608a53bf4937dcc4d62a55f55314e222addaa6
  zhaoxinKX6000Deb = requireFile {
    name = "zhaoxin-linux-graphics-driver-dri-glvnd_21.00.91_amd64.deb";
    url = "https://www.zhaoxin.com/";
    sha256 = "8fba2330241412c8195a953932608a53bf4937dcc4d62a55f55314e222addaa6";
  };

in
{
  nixpkgs.overlays = [
    (final: prev: {
      system-status = final.callPackage ./system-status.nix { };
      mihomo-tui = final.callPackage ./mihomo-tui.nix { };
      libadwaita-kde-kvantum = final.callPackage ./libadwaita-kde-kvantum.nix { };

      domino = final.callPackage ./domino.nix {
        inherit (inputs.erosanix.lib.${pkgs.system}) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
      };

      wine-d2d1-dcomp = final.callPackage ./wine-d2d1-dcomp.nix { };

      llama-cpp-turboquant = final.callPackage ./llama-cpp-turboquant.nix {
        inherit (prev) llama-cpp;
      };
      llama-cpp-turboquant-rocm = final.callPackage ./llama-cpp-turboquant.nix {
        llama-cpp = prev.llama-cpp.override { rocmSupport = true; };
      };
      llama-cpp-turboquant-cuda = final.callPackage ./llama-cpp-turboquant.nix {
        llama-cpp = prev.llama-cpp.override { cudaSupport = true; };
      };
      llama-cpp-turboquant-vulkan = final.callPackage ./llama-cpp-turboquant.nix {
        llama-cpp = prev.llama-cpp.override { vulkanSupport = true; };
      };

      zhaoxin-userspace-driver = final.callPackage ./zhaoxin/userspace.nix {
        debSrc = zhaoxinKX6000Deb;
      };

      linuxPackages = prev.linuxPackages.extend (
        lpFinal: lpPrev: {
          zhaoxin = lpFinal.callPackage ./zhaoxin/kernel-module {
            debSrc = zhaoxinKX6000Deb;
          };
        }
      );
    })
  ];

}
