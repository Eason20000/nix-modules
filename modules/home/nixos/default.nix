{ lib, my, osConfig, ... }:

{
  imports = [
    ./data.nix
    ./impermanence
    ./waydroid.nix
    ./kmscon-auto-tmux.nix
    ./tmux.nix
    ./xdg.nix
    ./ssh.nix
  ]
  ++ lib.optionals (my.lib.on osConfig "desktop") [ ./desktop ];

}
