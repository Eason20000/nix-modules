{
  debSrc,
  lib,
  stdenv,
  dpkg,
  kernel,
  kernelModuleMakeFlags ? [ ],
}:

let
  version = "21.00.73";
in
stdenv.mkDerivation {
  pname = "zhaoxin-graphics-driver";
  inherit version;

  passthru.moduleName = "zx";

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = [ dpkg ] ++ kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags;

  buildFlags = [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  unpackPhase = ''
    dpkg -x ${debSrc} .
  '';

  buildPhase = ''
    cd usr/src/zx-${version}
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      TARGET_ARCH=x86_64 \
      BIN_TYPE=x86_64 \
      DEBUG=0 \
      "-j$NIX_BUILD_CORES" \
      modules
  '';

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/updates
    cp zx.ko $out/lib/modules/${kernel.modDirVersion}/updates/
    cp zx_core.ko $out/lib/modules/${kernel.modDirVersion}/updates/
  '';

  meta = {
    maintainers = with lib.maintainers; [ ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    description = "Zhaoxin KX-6000 Graphics Driver (kernel modules, version ${version})";
    homepage = "https://www.zhaoxin.com/";
    longDescription = ''
      Kernel modules (zx.ko and zx_core.ko) for Zhaoxin KX-6000
      series integrated graphics. Builds against the target kernel.
    '';
  };
}
