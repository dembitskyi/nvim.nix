{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    snacks.enable = lib.mkEnableOption "Enable snacks module";
  };
  config = lib.mkIf config.snacks.enable {
    plugins = {
      snacks = {
        enable = true;
        settings = {
          indent.enabled = true;
          input.enabled = true;
          scroll.enabled = false;
          statuscolumn = {
            enabled = true;
            folds = {
              open = true;
            };
          };
          quickfile.enabled = true;
        };
      };
    };
    keymaps = lib.mkIf config.snacks.enable [
      {
        mode = "n";
        key = "<leader>gb";
        action.__raw = "function() Snacks.picker.git_log_line() end";
        options = {
          desc = "Git Blame Line";
        };
      }
      {
        mode = "n";
        key = "<leader>gL";
        action.__raw = "function() Snacks.picker.git_log() end";
        options = {
          desc = "Git Log (cwd)";
        };
      }
      {
        mode = "n";
        key = "<leader>gf";
        action.__raw = "function() Snacks.picker.git_log_file() end";
        options = {
          desc = "Git Current File History";
        };
      }
      {
        mode = [
          "x"
          "n"
        ];
        key = "<leader>gB";
        action.__raw = "function() Snacks.gitbrowse() end";
        options = {
          desc = "Git Browse (open)";
        };
      }
    ];
  };
}
