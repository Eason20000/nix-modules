# nix-modules

Eason20000's reusable [NixOS](https://nixos.org/),
[home-manager](https://github.com/nix-community/home-manager), and
[nix-darwin](https://github.com/LnL7/nix-darwin) modules.

## Usage

```nix
{
  inputs.nix-modules.url = "github:Eason20000/nix-modules";

  outputs = { nix-modules, ... }: {
    nixosConfigurations.HOST = nixpkgs.lib.nixosSystem {
      modules = [ nix-modules.nixosModules.default ];
    };

    darwinConfigurations.HOST = nix-darwin.lib.darwinSystem {
      modules = [ nix-modules.darwinModules.default ];
    };

    # Home-manager: wire via the system module layer instead
    # (nixosModules.default and darwinModules.default both handle
    #  home-manager integration internally.)
  };
}
```

`nixosModules.default` and `darwinModules.default` include the
home-manager bridge internally, so a standalone `homeModules.default`
import is only needed in setups that use home-manager independently.

| Module set | Layer |
|---|---|
| `nixosModules.default` | NixOS (also wires home-manager) |
| `darwinModules.default` | nix-darwin (also wires home-manager) |
| `homeModules.default` | home-manager (standalone) |

## Architecture

All options live under the `my` namespace, gated by layer:

- `my.nixos.*` — NixOS system modules
- `my.darwin.*` — nix-darwin system modules
- `my.home.*` — home-manager user modules

Each option set is behind an `enable` flag; modules activate with
`lib.mkIf cfg.enable`.

### Cross-layer reads

Home-manager modules read the system config via `my.lib.on`:

```nix
my.lib.on osConfig "desktop"  # → my.nixos.desktop.enable or false
```

This is safe across OS types: on macOS the same call returns `false`
because `my.nixos` is absent from the darwin config.

Available helpers in `my.lib`:

| Function | Purpose |
|---|---|
| `isNixOS osConfig` | True if config is from a NixOS host |
| `isDarwin osConfig` | True if config is from a Darwin host |
| `on osConfig "name"` | Read `my.nixos.<name>.enable` safely |
| `nixos osConfig "name"` | Read full `my.nixos.<name>` option set |
| `darwinOn osConfig "name"` | Read `my.darwin.<name>.enable` safely |
| `darwin osConfig "name"` | Read full `my.darwin.<name>` option set |

### Conditional OS imports

Home-manager modules conditionally import OS-specific submodules
using `lib.optionals`:

```
my.lib.isNixOS osConfig → imports ./nixos/...
my.lib.isDarwin osConfig → imports ./darwin/...
```

### Shared layers

`nixosModules.default` and `darwinModules.default` both include
`./pkgs` (an overlay with custom packages) and `./lib` (helper
functions). `homeModules.default` only includes `./modules/home`.

## Dependencies

| Input | Source |
|---|---|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-unstable` |
| `home-manager` | `github:nix-community/home-manager` |
| `sops-nix` | `github:Mic92/sops-nix` |
| `disko` | `github:nix-community/disko` |
| `impermanence` | `github:nix-community/impermanence` |
| `lanzaboote` | `github:nix-community/lanzaboote` |

All inputs follow the top-level `nixpkgs`.

## License

[GPL-3.0-only](./LICENSE)
