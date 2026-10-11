{ lib, ... }:
{
  imports = [
    ./ai/copilot.nix
    ./ai/minuet.nix
    ./completion
    ./editor.nix
    ./fzf-lua.nix
    ./git.nix
    ./keymaps.nix
    ./lsp
    ./options.nix
    ./ui.nix
  ];

  options.ai = {
    minuet.enable = lib.mkEnableOption "minuet-ai completion from the local LLM";
    copilot.enable = lib.mkEnableOption "GitHub Copilot completion";
  };

  # Plugins with `lazyLoad` are loaded by lz-n on their trigger; lzn-auto-require
  # loads them on first `require` too (e.g. from a keymap).
  config.plugins = {
    lz-n.enable = true;
    lzn-auto-require.enable = true;
  };

  # One-line keymap constructors shared by all modules.
  config._module.args.km = {
    # rhs is a Vim command/key sequence or a raw Lua value.
    map = mode: key: action: desc: {
      inherit mode key action;
      options = {
        inherit desc;
        silent = true;
      };
    };
    # rhs is a Lua statement, wrapped in a function.
    lua = mode: key: code: desc: {
      inherit mode key;
      action.__raw = "function() ${code} end";
      options = {
        inherit desc;
        silent = true;
      };
    };
  };
}
