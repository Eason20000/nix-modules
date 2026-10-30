# nix-modules

Reusable NixOS, nix-darwin, and home-manager modules under the `my.*`
namespace, plus a small package overlay and the `my.lib` helpers.

This repository intentionally contains **no secrets and no SOPS wiring**. Host
definitions, users, and secret files belong in the consuming configuration.

## Outputs

| Output | Description |
|--------|-------------|
| `nixosModules.default` | NixOS modules, package overlay, and `my.lib` |
| `darwinModules.default` | nix-darwin modules, package overlay, and `my.lib` |
| `homeModules.default` | home-manager modules and `my.lib` |
| `homeManagerModules.default` | Alias for `homeModules.default` |
| `lib.my` | `my.lib` helpers (`isNixOS`, `isDarwin`, `queryHosts`, ...) |
| `formatter` | `nixfmt-tree` with `strict = true`, `width = 80` |

## Required inputs

The modules reference dependencies through the consumer's flake `inputs`, so a
consuming flake must provide:

- `nixpkgs`
- `home-manager`
- `impermanence`
- `lanzaboote`
- `nix-flatpak`
- `gamemaker-flake`
- `erosanix`
- `prelude`
- `nix-homebrew`
- `homebrew-core`
- `homebrew-cask`

## Usage

```nix
{
  inputs.nix-modules.url = "github:Eason20000/nix-modules";
  inputs.nix-modules.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-modules.inputs.home-manager.follows = "home-manager";
  inputs.nix-modules.inputs.impermanence.follows = "impermanence";
  inputs.nix-modules.inputs.lanzaboote.follows = "lanzaboote";
  inputs.nix-modules.inputs.nix-flatpak.follows = "nix-flatpak";
  inputs.nix-modules.inputs.gamemaker-flake.follows = "gamemaker-flake";
  inputs.nix-modules.inputs.erosanix.follows = "erosanix";
  inputs.nix-modules.inputs.prelude.follows = "prelude";
  inputs.nix-modules.inputs.nix-homebrew.follows = "nix-homebrew";
  inputs.nix-modules.inputs.homebrew-core.follows = "homebrew-core";
  inputs.nix-modules.inputs.homebrew-cask.follows = "homebrew-cask";

  outputs = { self, nixpkgs, nix-modules, ... }@inputs: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        nix-modules.nixosModules.default
        ./hosts/example
      ];
    };
  };
}
```

The consuming host must set the required `my.nixos.base` options and connect any
secret files itself. For example, `my.nixos.ssh.reverseProxy.identityFile`,
`my.nixos.buildMachine.sshKeyFile`, and
`my.nixos.remoteDiskUnlock.tunnelKeyFile` are paths supplied by the consumer.

## Secrets

This repository does not depend on `sops-nix`, does not contain `.sops.yaml`,
and does not reference a `secrets/` directory. Modules accept paths or values
through options; encrypted-file handling belongs to the consumer.

`modules/nixos/remote-disk-unlock.nix` still uses the generic
`boot.initrd.secrets` NixOS option to mount a key into the initrd. The
destination path is configurable via `my.nixos.remoteDiskUnlock.tunnelKeyPath`.

## Packages requiring local files

Some packages use `requireFile` and therefore need local files at build time:

- `pkgs/zhaoxin`: the vendor Zhaoxin graphics driver `.deb`. The kernel
  module also drops the 10-bit plane formats: the vendor
  `DrmFormat2CBiosFormat()` only maps `ARGB2101010`, so compositors that pick
  `XRGB2101010` (GNOME/Mutter does) get their 10-bit buffer decoded as 8-bit
  ARGB and colors are corrupted. 8-bit scanout is forced until the mapping is
  fixed and tested.
- `modules/nixos/mcc-netboot.nix`: the `mcc-netboot.tar` archive.

## Verification

There is no CI, test suite, or devShell. Verify changes by building a consuming
host, and run `nix fmt` before committing.

## Documentation

This README and `AGENTS.md` are part of the public interface. Update them in the
same commit when outputs, required inputs, module behavior, package notes, or
the verification workflow changes.

## License

GPL-3.0-only. See `LICENSE`.
