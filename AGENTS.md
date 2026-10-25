# AGENTS.md

Reusable Nix module library. Consumed by personal private configurations through
the flake outputs `nixosModules`, `darwinModules`, and `homeModules` (plus the
`homeManagerModules` alias), along with `lib.my` and `formatter`.

## Layout

```
flake.nix                 ← outputs, inputs, formatter
lib/                      ← my.lib helpers; imported by all module outputs
common/nix-substituters.nix
modules/common/           ← shared home-manager wiring
modules/nixos/            ← NixOS modules under options.my.nixos.*
modules/darwin/           ← nix-darwin modules under options.my.darwin.*
modules/home/             ← home-manager modules under options.my.home.*
pkgs/                     ← nixpkgs overlay applied by nixos/darwin modules
```

## Module convention

All custom options live under `my`:

- NixOS: `options.my.nixos.<feature>`; read via `config.my.nixos.*`.
- Darwin: `options.my.darwin.<feature>`; read via `config.my.darwin.*`.
- Home-manager: `options.my.home.<feature>`; read via `config.my.home.*`.

A module's `config` block reads options via `config.my.*`, not the `my` argument
(which only carries `my.lib`).

## Paths

Public modules use relative imports. Do **not** add a repo-root helper such as
`my.lib.fromRoot`; this library may be imported from a flake input, where the
consumer's repo root is different.

## Secrets policy

This repository must remain completely decoupled from secrets:

- No `sops-nix` input or imports.
- No `.sops.yaml`, `secrets/` directory, or encrypted files.
- No hardcoded secret paths or secret values.
- Modules may accept paths/values through options (for example
  `sshKeyFile`, `identityFile`, `tunnelKeyFile`); the consumer wires SOPS.

`boot.initrd.secrets` in `remote-disk-unlock.nix` is a generic NixOS option and
is not SOPS coupling.

## Required consumer inputs

The modules reference the consumer's `inputs` for `home-manager`,
`impermanence`, `lanzaboote`, `nix-flatpak`, `gamemaker-flake`, `erosanix`,
`prelude`, `nix-homebrew`, `homebrew-core`, and `homebrew-cask`. Keep the
README input list in sync.

## Format

`nix fmt` (nixfmt-tree, `strict = true`, `width = 80`). Do not call `nixfmt`
directly.

## Verification

No CI, tests, devShell, or flake checks. Verify by building a consuming host;
`nix flake show` only checks the output shape.

## Local files

`pkgs/zhaoxin` and `modules/nixos/mcc-netboot.nix` use `requireFile`. They only
need the local file when the affected derivation is built.

## Documentation boundary

Every change to outputs, required consumer inputs, module behavior/conventions,
package local-file notes, or the verification workflow must update this
`AGENTS.md` and/or `README.md` in the same commit. If consumers must update
their flake input or lockfile, call that out in the commit body.

## Commit style

Conventional Commits, matching the consuming repos: `type(scope): description`
with `- ` bullet points in the body.

## License

GPL-3.0-only.
