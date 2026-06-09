# nvim.nix

A nixified Neovim config built on [nixvim](https://github.com/nix-community/nixvim),
exposed as a flake. Two profiles:

- **home** — local LLM completion via Ollama + [minuet-ai](https://github.com/milanglacier/minuet-ai.nvim).
- **work** — GitHub Copilot.

## Run it

```sh
nix run github:dembitskyi/nvim.nix         # = #home
nix run github:dembitskyi/nvim.nix#work
```

## Use as a home-manager module

```nix
{
  inputs.nvim-nix.url = "github:dembitskyi/nvim.nix";

  # In your home-manager config:
  imports = [ inputs.nvim-nix.homeModules.default ];
  programs.nvim-nix = {
    enable = true;
    profile = "home";  # or "work"
  };
}
```

## Configure the local LLM

The `home` profile points minuet-ai at an Ollama endpoint hard-coded in
[`config/plugins/ai/minuet-ai.nix`](config/plugins/ai/minuet-ai.nix). Edit
`end_point` and `model` (default: `Qwen3.6-35B-A3B`) to match your server.

## Flake outputs

| Output | Purpose |
| --- | --- |
| `packages.<system>.{home,work,default}` | Standalone wrapped Neovim. |
| `homeModules.default` | Home-manager module (see above). |
| `nixvimModules.{home,work}` | Raw nixvim modules for ad-hoc composition. |
