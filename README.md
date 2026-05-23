# nvim.nix

A nixified [Neovim](https://neovim.io/) configuration built on top of
[nixvim](https://github.com/nix-community/nixvim) and exposed as a flake.

The configuration is split into composable modules (LSP, completion, AI, UI,
keymaps, ...) and ships two ready-to-run profiles:

- `home` — personal setup, uses a local LLM (Ollama via
  [minuet-ai](https://github.com/milanglacier/minuet-ai.nvim)) for completion.
- `work` — same base config, swaps the local LLM for GitHub Copilot.

## Quick start

Run it directly without installing anything:

```sh
nix run github:dembitskyi/nvim.nix              # default profile (home)
nix run github:dembitskyi/nvim.nix#home
nix run github:dembitskyi/nvim.nix#work
```

Install it into your profile:

```sh
nix profile install github:dembitskyi/nvim.nix
```

## Using it in your own flake

The flake exports `nixvimModules` so you can compose the profiles into your own
nixvim build (e.g. to add machine-specific overrides):

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    nvim-nix.url = "github:dembitskyi/nvim.nix";
  };

  outputs = { nixpkgs, nixvim, nvim-nix, ... }: {
    packages.x86_64-linux.default =
      nixvim.legacyPackages.x86_64-linux.makeNixvimWithModule {
        module = {
          imports = [ nvim-nix.nixvimModules.home ];
          # your overrides here
        };
      };
  };
}
```

## Layout

```
flake.nix                         # entry point, defines profiles + packages
config/
  home.nix                        # personal profile
  work.nix                        # work profile (Copilot)
  plugins/
    keys.nix                      # leader/global keymaps
    lsp.nix, lsp/*.nix            # LSP servers (clangd, ccls, rust-analyzer, ...)
    blink/                        # blink.cmp completion engine
    ai/                           # copilot + minuet-ai (Ollama)
    snacks/                       # snacks.nvim (dashboard, pickers, ...)
    mini/                         # mini.nvim modules
    sets/                         # vim options
    utils/                        # fzf-lua, which-key, lazygit, gitsigns, ...
```

Each module follows the same shape: an `mkEnableOption` toggle plus a
`mkIf cfg.enable` body, so profiles only opt in to what they need.

## Local LLM (`home` profile)

The `home` profile expects an [Ollama](https://ollama.com/) server reachable
over HTTP. The endpoint is hard-coded in
[`config/plugins/ai/minuet-ai.nix`](config/plugins/ai/minuet-ai.nix) — adjust
`end_point` and `model` to point at your own server (default model:
`qwen2.5-coder:14b`).

## References

- [nixvim](https://github.com/nix-community/nixvim) —
  [user guide](https://nix-community.github.io/nixvim/user-guide/config-examples.html)
- [Neve](https://github.com/redyf/Neve) — another nixvim config used as a
  reference
