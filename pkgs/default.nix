{ inputs, pkgs, ... }:

let
  inherit (pkgs) requireFile;

  # Source .deb for Zhaoxin graphics driver (kernel + userspace).
  # sha256: 5ec02b38291464bc11c945dd251379fc828af8da8c62f10cd5dd7351690c3fef
  zhaoxinKX6000Deb = requireFile {
    name = "zhaoxin-linux-graphics-driver-dri-glvnd-21.00.73_amd64.deb";
    url = "https://www.zhaoxin.com/";
    sha256 = "5ec02b38291464bc11c945dd251379fc828af8da8c62f10cd5dd7351690c3fef";
  };

in
{
  nixpkgs.overlays = [
    (final: prev: {
      system-status = final.callPackage ./system-status.nix { };
      mihomo-tui = final.callPackage ./mihomo-tui.nix { };

      llama-cpp-turboquant = final.callPackage ./llama-cpp-turboquant.nix {
        inherit (prev) llama-cpp;
      };
      llama-cpp-turboquant-rocm = final.callPackage ./llama-cpp-turboquant.nix {
        llama-cpp = prev.llama-cpp.override { rocmSupport = true; };
      };

      zhaoxin-userspace-driver = final.callPackage ./zhaoxin-userspace-driver.nix {
        debSrc = zhaoxinKX6000Deb;
      };

      linuxPackages_6_6 = prev.linuxPackages_6_6.extend (
        lpFinal: lpPrev: {
          zhaoxin = lpFinal.callPackage ./zhaoxin-graphics-driver.nix {
            debSrc = zhaoxinKX6000Deb;
          };
        }
      );
    })
  ];

}
