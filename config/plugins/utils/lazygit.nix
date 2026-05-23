{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    lazygit.enable = lib.mkEnableOption "Enable lazygit module";
  };
  config = lib.mkIf config.lazygit.enable {
    plugins = {
      lazygit = {
        enable = true;
      };
    };
    keymaps = lib.mkIf config.plugins.lazygit.enable [
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>LazyGit<CR>";
        options = {
          desc = "Open LazyGit";
        };
      }
    ];
  };
}
