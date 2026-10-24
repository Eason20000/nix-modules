{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.my.nixos.mcc-netboot.server;

  archive = pkgs.requireFile {
    name = "mcc-netboot.tar";
    sha256 = "8c4468b1b2a3f09ed5ffc64dab8e57d3c337bd7a87eba77560a185e97a142290";
    message = "please add mcc-netboot.tar";
  };

  sys = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      (
        {
          config,
          pkgs,
          lib,
          modulesPath,
          ...
        }:
        {
          imports = [
            (modulesPath + "/installer/netboot/netboot-base.nix")
            ../../pkgs
            ./hardware
          ];
          config = {
            netboot.squashfsCompression = "zstd -Xcompression-level 6";

            boot.initrd.availableKernelModules = [
              "r8169"
              "e1000e"
            ];

            boot.initrd.systemd.emergencyAccess = true;

            boot.initrd.systemd.network = {
              enable = true;
              networks."10-wired" = {
                matchConfig.Name = "en*";
                networkConfig = {
                  DHCP = "yes";
                };
              };
            };

            boot.initrd.systemd.storePaths = [ pkgs.aria2 ];
            boot.initrd.systemd.services.download-squashfs = {
              description = "Download Nix Store SquashFS";
              wantedBy = [ "initrd-fs.target" ];
              after = [
                "network-online.target"
                "sysroot.mount"
              ];
              requires = [
                "network-online.target"
                "sysroot.mount"
              ];
              before = [ "sysroot-nix-.ro\\x2dstore.mount" ];
              requiredBy = [ "sysroot-nix-.ro\\x2dstore.mount" ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
              script = ''
                HOST_IP=""
                for o in $(cat /proc/cmdline); do
                  case "$o" in
                    host_ip=*)  HOST_IP="''${o#host_ip=}" ;;
                  esac
                done
                [ -n "$HOST_IP" ]  || { echo "FATAL: no host_ip=";  exit 1; }
                rm -f /sysroot/nix-store.squashfs.*
                ${pkgs.aria2}/bin/aria2c \
                  --allow-overwrite=true \
                  --auto-file-renaming=false \
                  --follow-torrent=false \
                  --dir=/sysroot \
                  --out=nix-store.squashfs.torrent \
                  "http://$HOST_IP:8080/nix-store.squashfs.torrent"
                ${pkgs.aria2}/bin/aria2c \
                  --allow-overwrite=true \
                  --auto-file-renaming=false \
                  --enable-dht=false \
                  --bt-enable-lpd=true \
                  --bt-tracker="http://$HOST_IP:6969/announce" \
                  --seed-time=0 \
                  --dir=/sysroot \
                  -T "/sysroot/nix-store.squashfs.torrent" \
                  "http://$HOST_IP:8080/nix-store.squashfs"
                touch /nix-store.squashfs
                mount -o bind /sysroot/nix-store.squashfs /nix-store.squashfs
              '';
            };

            systemd.services.mcc-netboot-seeder = {
              description = "MCC Netboot SquashFS Seeder";
              wantedBy = [ "multi-user.target" ];
              after = [ "network-online.target" ];
              requires = [ "network-online.target" ];
              serviceConfig = {
                Type = "simple";
                Restart = "always";
              };
              script = ''
                HOST_IP=""
                for o in $(cat /proc/cmdline); do
                  case "$o" in
                    host_ip=*)  HOST_IP="''${o#host_ip=}" ;;
                  esac
                done
                [ -n "$HOST_IP" ]  || { echo "FATAL: no host_ip=";  exit 1; }
                ${pkgs.aria2}/bin/aria2c \
                  --enable-dht=false \
                  --bt-enable-lpd=true \
                  --bt-tracker="http://$HOST_IP:6969/announce" \
                  --seed-ratio=0.0 \
                  --bt-seed-unverified \
                  --listen-port=6890 \
                  --dir=/ \
                  /nix-store.squashfs.torrent
              '';
            };
            networking.firewall.allowedTCPPorts = [ 6890 ];

            systemd.services.extract-mcc-archive = {
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                User = "nixos";
                Group = "users";
              };

              script = ''
                ${pkgs.gnutar}/bin/tar -xvf ${archive} -C /home/nixos
              '';
            };

            time.timeZone = "Asia/Shanghai";
            i18n.defaultLocale = "zh_CN.UTF-8";

            system.stateVersion = config.system.nixos.release;

            nixpkgs.config.allowUnfree = true;
            my.nixos = {
              hardware = {
                # Follows the default kernel (my.nixos.hardware.zhaoxin
                # no longer pins linuxPackages_6_6). Big-initrd boot
                # issues (nixpkgs#203593) were bypassed with the initrd
                # squashfs download below; re-verify on real machines
                # after kernel bumps.
                # https://github.com/NixOS/nixpkgs/issues/203593
                # https://github.com/NixOS/nixpkgs/pull/203750
                zhaoxin.enable = true;
                zramSwap.enable = true;
              };
            };

            services.xserver = {
              enable = true;
              desktopManager = {
                xterm.enable = false;
                xfce = {
                  enable = true;
                  enableScreensaver = false;
                };
              };
            };
            services.displayManager = {
              defaultSession = "xfce";
              autoLogin.user = "nixos";
            };

            i18n.inputMethod = {
              type = "fcitx5";
              enable = true;
              fcitx5.addons = with pkgs; [
                fcitx5-gtk
                qt6Packages.fcitx5-chinese-addons
              ];
            };

            programs.firefox.enable = true;

            environment.systemPackages = with pkgs; [ hmcl ];

            boot = {
              kernelParams = [
                "quiet"
                "rd.udev.log_level=3"
                "rd.systemd.show_status=auto"
              ];
              consoleLogLevel = 3;
              initrd.verbose = false;
              plymouth.enable = true;
            };

            security.rtkit.enable = true;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              pulse.enable = true;
              jack.enable = true;
            };

            hardware.bluetooth = {
              enable = true;
              powerOnBoot = true;
              settings = {
                General = {
                  Experimental = true;
                  FastConnectable = true;
                };
              };
            };

            fonts = {
              fontDir.enable = true;
              enableDefaultPackages = true;
              packages = with pkgs; [
                corefonts
                noto-fonts
                noto-fonts-cjk-sans
                noto-fonts-cjk-serif
                noto-fonts-color-emoji
              ];
              fontconfig = {
                defaultFonts = {
                  sansSerif = [
                    "Noto Sans"
                    "Noto Sans CJK SC"
                  ];
                  serif = [
                    "Noto Serif"
                    "Noto Serif CJK SC"
                  ];
                  monospace = [
                    "Noto Sans Mono"
                    "Noto Sans Mono CJK SC"
                  ];
                };
              };
            };

          };
        }
      )
    ];
  };

  squashfsTorrent =
    pkgs.runCommand "nix-store.squashfs.torrent" { nativeBuildInputs = [ pkgs.mktorrent ]; }
      ''
        ln -s "${sys.config.system.build.squashfsStore}" nix-store.squashfs
        mktorrent -o $out nix-store.squashfs
      '';

in
{
  options.my.nixos.mcc-netboot.server = {
    enable = lib.mkEnableOption "PXE netboot server for Minecraft club";
  };

  config = lib.mkIf cfg.enable {
    services.pixiecore = {
      enable = true;
      openFirewall = true;
      dhcpNoBind = true;
      kernel = "${sys.config.system.build.kernel}/bzImage";
      initrd = "${sys.config.system.build.initialRamdisk}/initrd";
      cmdLine = "init=${sys.config.system.build.toplevel}/init host_ip=$\${next-server} loglevel=4";
    };

    systemd.tmpfiles.rules = [
      "L+ /var/lib/mcc-netboot/nix-store.squashfs.torrent - - - - ${squashfsTorrent}"
      "L+ /var/lib/mcc-netboot/nix-store.squashfs - - - - ${sys.config.system.build.squashfsStore}"
    ];

    systemd.services.mcc-netboot-files = {
      description = "MCC Netboot SquashFS HTTP Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.darkhttpd}/bin/darkhttpd /var/lib/mcc-netboot --port 8080 --no-server-id";
        Restart = "always";
      };
    };
    services.opentracker.enable = true;
    networking.firewall.allowedTCPPorts = [
      8080
      6969
    ];

  };
}
