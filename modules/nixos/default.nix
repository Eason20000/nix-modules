{ ... }:

{
  imports = [
    ./base.nix
    ./data.nix
    ./desktop.nix
    ./impermanence.nix
    ./kmscon.nix
    ./mcc-netboot
    ./ollama.nix
    ./remote-disk-unlock.nix
    ./secure-boot.nix
    ./ssh.nix
    ./virtualisation.nix
    ./waydroid.nix
    ./home-manager.nix
    ./hardware
    ./build-machine.nix
    ./norgb.nix
    ./static-ipv4.nix
    ./llama-cpp.nix
  ];

}
