# Hive Starter

This repository contains a `divnix/hive` setup on top of `divnix/std`,
translated to stay close to the layout from `~/nixos`.

Layout:

- `./systems/<name>/target.nix`: exposes each host or phone target
- `./systems/<name>/config.nix`: owns each system configuration
- `./programs/*.nix` and subdirs: reusable program feature modules
- `./home/*.nix`: Home Manager and overlay glue
- `./pkgs/*.nix`: custom installable derivations
- `./lib/*.nix`: supporting files that preserve the old composition logic
- `./systems/phone/home.nix`: phone Home Manager configuration

Optional `signal-bot`-style run targets are supported through:

- `./programs/config.nix`
- `./programs/shell.nix`
- `./programs/run.nix`
- `./pkgs/run.nix`

Any folder such as `programs/<name>/` or `pkgs/<name>/` can contain:

- `module.nix`: the canonical module logic for that folder. In `programs/`,
  this is where the reusable `{ home = ...; nixos = ...; }` blocks live.
- `package.nix`: shared package- and service-adjacent definitions reused by
  `config.nix`, `module.nix`, `run.nix`, and `shell.nix`
- `config.nix`: the main place for tunable values and reusable configuration
  data for the folder
- `run.nix`: a self-contained runnable leaf that decides exactly how to
  launch itself from the shared package/config values
- `shell.nix`: an optional std-managed dev shell for the leaf

`config.nix` is a scoped attrset, not a function. The loader auto-imports the
same broad scope used by the sibling `module.nix`, `run.nix`, and `shell.nix`
files. That scope includes `inputs`, every flake input as a direct name, and
common values such as `cell`, `pkgs`, `lib`, `colors`, `system`, `user`, `host`,
`rootConfig`, `context`, `modules`, `module`, `folderName`, and `moduleName`.
For example: `{ output = { package = inputs.foo.packages.${system}.default; }; }`.

The loader normalizes the `output` block, publishes it through
`cell.config.<name>`, and injects those values into the sibling imports. A value
such as `output.cfg` can be used directly as a `cfg` function argument in those
files.

If `package.nix` exists, the loader imports it automatically and exposes the
result as `packageConfig` to the sibling files. This keeps package and service
definitions in one place while letting `config.nix` focus on configuration
values and `run.nix` focus on the runner wrapper.

For std-managed program cells, `module.nix` exposes evaluated program modules,
`config.nix` carries the primary tunables, `package.nix` carries shared
package/service definitions, `shell.nix` consumes those values for a dev
environment, and `run.nix` consumes them for runtime behavior.

Program host/home composition is defined in the host files themselves.
Flake-facing runner visibility is defined in std-managed `programs/config.nix`
and `pkgs/config.nix`. Top-level `packages` only expose harvested runner
outputs, not the entire internal custom package set.

The repo-level loaders use `lib/cell-loader.nix`, so every folder leaf receives
the same rich argument set: `inputs`, `cell`, `pkgs`, `lib`, `colors`, `system`,
`user`, `host`, `rootConfig`, `context`, `modules`, `module`, and `config` where
applicable. For a program folder, `module` is that folder's evaluated
`module.nix`; `modules.<name>.home` and `modules.<name>.nixos` are available to
all sibling `config.nix`, `run.nix`, and `shell.nix` files.

Current examples:

- `programs/firefox/{module.nix,package.nix,config.nix}`
- `programs/mnw/{module.nix,config.nix,run.nix}`
- `programs/caelestia/{module.nix,package.nix,config.nix,run.nix}`
- `programs/soft-serve/{module.nix,package.nix,config.nix,run.nix}`
- `programs/sops/{module.nix,config.nix}`
- `programs/spacebot/{module.nix,package.nix,config.nix,run.nix,shell.nix}`
- `programs/spacedrive/{module.nix,package.nix,config.nix,run.nix}`

System targets live beside their system configs:

- `systems/notebook/{target.nix,config.nix,hardware.nix,filesystem.nix,loq-15IRH8.nix,attic.nix,build-telemetry.nix}`
- `systems/vm/{target.nix,config.nix}`
- `systems/phone/{target.nix,config.nix,home.nix}`

The other top-level directories are plain repo folders, like in the old
configuration.

Outputs:

- `systems/notebook/target.nix` exposes `notebook` as `.#nixosConfigurations.notebook`
- `systems/vm/target.nix` exposes `vm` as `.#nixosConfigurations.vm`
- `systems/phone/target.nix` exposes `phone` as `.#nixOnDroidConfigurations.phone`
- harvested runnable outputs become available under `.#packages.<system>.<name>`

Useful commands:

```bash
nix flake show
nix build .#nixosConfigurations.notebook.config.system.build.toplevel
nix fmt
nix-on-droid switch --flake .#phone
nix run .#mnw
nix run .#caelestia
nix run .#spacebot
nix run .#spacedrive
```
