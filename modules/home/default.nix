{
  lib,
  my,
  osConfig,
  ...
}:

{
  imports = [
    ./ssh-auto-tmux.nix
    ./base.nix
    ./nano.nix
    ./tmux.nix
    ./ssh.nix
  ]
  ++ lib.optionals (my.lib.isNixOS osConfig) [ ./nixos ]
  ++ lib.optionals (my.lib.isDarwin osConfig) [ ./darwin ];

}
