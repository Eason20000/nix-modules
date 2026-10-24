{
  debSrc,
  lib,
  stdenv,
  dpkg,
  kernel,
}:

let
  version = "21.00.91";

  # Patches taken from AOSC (via TVL depot), irrelevant patches (DKMS etc.)
  # dropped. 0008-0009 is TVL's rebase of AOSC 0008+0009 onto 21.00.91.
  # https://github.com/AOSC-Dev/aosc-os-abbs/tree/stable/runtime-display/zhaoxin-linux-graphics-driver-dri
  modulePatches = [
    ./0001-fix-kbuild-replace-EXTRA_CFLAGS-with-ccflags-y.patch
    ./0003-fix-kernel-6.15.patch
    ./0004-fix-kernel-6.16.patch
    ./0005-fix-kernel-6.17.patch
    ./0006-fix-kernel-6.18.patch
    ./0008-0009-fbdev-6.15-rebase-21.00.91.patch
    ./0010-fix-adapt-for-shmem_file_setup-parameter-change-in-L.patch
    ./0011-fix-remove-zx_drm_last_close-on-Linux-6.12.patch
    ./0012-fix-adapt-for-drm_fb_helper_alloc_info-removal-in-Li.patch
    ./0013-refactor-make-the-fbdev-ptr-in-zx_card_t-typed.patch
    ./0014-refactor-Remove-load-callback-from-kms_driver.patch
    ./0015-refactor-make-to_zx_fbdev-use-the-helper-ptr-stored-.patch
    ./0016-refactor-Suspend-resume-fbdev-emulation-via-client-i.patch
    ./0017-refactor-use-helper-instead-of-fbdev-helper-21.00.91.patch
    ./0018-fix-take-out-embedded-fb_helper-in-zx_fbdev-with-Lin.patch
    # Local delta (not upstream): holds_console_lock removal backported
    # to 6.18.55, see patch header for links.
    ./0019-fix-adapt-for-holds_console_lock-removal.patch
  ];
in
stdenv.mkDerivation {
  pname = "zhaoxin-graphics-driver";
  inherit version;

  passthru.moduleName = "zx";

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = [ dpkg ] ++ kernel.moduleBuildDependencies;
  dontPatchELF = true;
  patches = modulePatches;

  unpackPhase = ''
    runHook preUnpack
    dpkg -x ${debSrc} deb_contents
    sourceRoot=deb_contents/usr/src/zx-${version}
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M="$PWD" \
      "-j$NIX_BUILD_CORES" \
      modules
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/updates
    cp zx.ko $out/lib/modules/${kernel.modDirVersion}/updates/
    cp zx_core.ko $out/lib/modules/${kernel.modDirVersion}/updates/
    runHook postInstall
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
