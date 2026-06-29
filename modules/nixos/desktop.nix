{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.desktop;

in
{
  options.my.nixos.desktop = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    services = {
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };
      gnome.gnome-remote-desktop.enable = true;
    };

    services.gnome.gnome-software.enable = lib.mkForce false;

    networking.firewall = rec {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };

    boot = {
      kernelParams = [
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];
      consoleLogLevel = 3;
      initrd.verbose = false;
      plymouth.enable = true;
      loader.timeout = 0;
    };

    services.ratbagd.enable = true;
    services.flatpak.enable = true;
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplipWithPlugin
        splix
      ];
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
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
        adwaita-fonts
        nerd-fonts.adwaita-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];
      fontconfig = {
        defaultFonts = {
          sansSerif = [
            "Adwaita Sans"
            "Noto Sans CJK SC"
          ];
          serif = [
            "Noto Serif"
            "Noto Serif CJK SC"
          ];
          monospace = [
            "AdwaitaMono Nerd Font"
            "Noto Sans Mono CJK SC"
          ];
        };
      };
    };

    environment.gnome.excludePackages = [ pkgs.gnome-tour ];

    environment.systemPackages = with pkgs; [
      file-roller
      mission-center
      nufraw-thumbnailer
    ];

    programs.dconf.profiles.gdm.databases = [
      {
        lockAll = true;
        settings = {
          "org/gnome/desktop/interface" = {
            document-font-name = "Sans 11";
            font-name = "Sans 11";
            monospace-font-name = "Monospace 11";
          };
          "org/gnome/mutter" = {
            experimental-features = [ "scale-monitor-framebuffer" ];
          };
        };
      }
    ];

    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        (rime.override {
          rimeDataPkgs = with pkgs; [
            rime-data
            rime-zhwiki
            rime-moegirl
            rime-ice
          ];
        })
      ];
    };

    environment.variables = {
      "GTK_IM_MODULE" = lib.mkForce null;
      "QT_IM_MODULE" = lib.mkForce null;
    };

  };

}
