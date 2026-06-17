{ inputs, ... }:

{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    uninstallUnmanaged = true;
    update.onActivation = true;

    packages = [
      "com.tencent.WeChat"
      "com.qq.QQ"
      "com.dingtalk.DingTalk"
    ];

  };

  my.home.impermanence.extraDirectories = [
    ".local/share/flatpak"
    ".var/app/com.tencent.WeChat"
    ".var/app/com.qq.QQ"
    ".var/app/com.dingtalk.DingTalk"
  ];

}
