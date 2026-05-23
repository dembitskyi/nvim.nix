{ lib, config, ... }:
{
  imports = [
    ./markdown-preview.nix
    ./fzf-lua.nix
    ./which-key.nix
    ./hot-fixes.nix
    ./flash.nix
    ./lazygit.nix
    ./gitsigns.nix
  ];

  options = {
    utils.enable = lib.mkEnableOption "Enable utils module";
  };
  config = lib.mkIf config.utils.enable {
    markdown-preview.enable = true;
    fzf-lua.enable = true;
    which-key.enable = true;
    hot-fixes.enable = true;
    flash.enable = true;
    lazygit.enable = true;
    gitsigns.enable = true;
  };
}
