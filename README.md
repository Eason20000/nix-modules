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
  };
}
```

| Module set | Layer |
|---|---|
| `nixosModules.default` | NixOS |
| `homeModules.default` | home-manager |
| `darwinModules.default` | nix-darwin |

## License

[GPL-3.0-only](./LICENSE)
