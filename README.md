# nvim.nix

A nixified Neovim config built on [nixvim](https://github.com/nix-community/nixvim),
exposed as a flake. Two profiles:

- **home**: local LLM completion via [minuet-ai](https://github.com/milanglacier/minuet-ai.nvim)
  against an OpenAI-compatible server (vLLM behind llama-swap).
- **work**: GitHub Copilot (`:Copilot auth` to sign in).

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
    profile = "home"; # or "work"
    # Optional, default from the profile:
    # ai.minuet.enable = false;
    # ai.copilot.enable = true;
  };
}
```

## Layout

| Path | Contents |
| --- | --- |
| `config/default.nix` | Imports, `ai.*` toggles, the `km` keymap helpers |
| `config/options.nix` | Vim options |
| `config/keymaps.nix` | General keymaps and `<leader>u` toggles |
| `config/ui.nix` | mini.nvim, snacks, treesitter, which-key |
| `config/editor.nix` | flash, markdown-preview, conform (format on save) |
| `config/fzf-lua.nix`, `config/git.nix` | Pickers; gitsigns, lazygit |
| `config/lsp/` | Language servers and LSP keymaps |
| `config/completion/` | blink.cmp and its sources |
| `config/ai/` | minuet and Copilot, each with its blink provider |

## Configure the local LLM

Edit `end_point` and `model` (default: `Qwen3.6-35B-A3B`) in
[`config/ai/minuet.nix`](config/ai/minuet.nix). No request is sent until you
type in insert mode.

## Git completion

In commit messages, issue/PR/@mention completion comes from the forge CLI.
It turns itself on only when `gh` (GitHub) or `glab` (GitLab) is logged in,
so there are no errors without a login.

## Flake outputs

| Output | Purpose |
| --- | --- |
| `packages.<system>.{home,work,default}` | Standalone wrapped Neovim. |
| `homeModules.default` | Home-manager module (see above). |
| `nixvimModules.{home,work}` | Raw nixvim modules for ad-hoc composition. |
