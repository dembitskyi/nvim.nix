{ ... }:
{
  imports = [
    ./plugins/keys.nix
    ./plugins/lsp.nix
    ./plugins/sets
    ./plugins/utils
    ./plugins/ai
    ./plugins/snacks
    ./plugins/blink
    ./plugins/mini
  ];

  ai.minuet.enable = true;
  keys.enable = true;
  sets.enable = true;
  utils.enable = true;
  snacks.enable = true;
  blink.enable = true;
}
