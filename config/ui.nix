{ lib, ... }:
{
  plugins = {
    mini-basics.enable = true;
    mini-bracketed.enable = true;
    mini-align.enable = true;
    mini-icons = {
      enable = true;
      mockDevIcons = true;
    };
    # Expands LSP snippets for blink; also loads snippets/<lang>.json from runtimepath.
    mini-snippets = {
      enable = true;
      settings.snippets = [ { __raw = "require('mini.snippets').gen_loader.from_lang()"; } ];
    };

    snacks = {
      enable = true;
      settings = {
        indent.enabled = true;
        input.enabled = true;
        quickfile.enabled = true;
        statuscolumn = {
          enabled = true;
          folds.open = true;
        };
      };
    };

    treesitter = {
      enable = true;
      highlight.enable = true;
      folding.enable = true;
    };

    which-key = {
      enable = true;
      settings = {
        icons = {
          breadcrumb = "»";
          group = "+";
          separator = "";
        };
        win = {
          border = "none";
          wo.winblend = 0;
        };
        spec =
          lib.mapAttrsToList
            (key: group: {
              __unkeyed-1 = key;
              inherit group;
              mode = [
                "n"
                "v"
              ];
            })
            {
              "<leader><tab>" = "+tab";
              "<leader>c" = "+code";
              "<leader>f" = "+find/file";
              "<leader>g" = "+git";
              "<leader>gh" = "+hunks";
              "<leader>l" = "+lsp";
              "<leader>q" = "+quit";
              "<leader>s" = "+search";
              "<leader>u" = "+ui";
              "<leader>uc" = "+completion";
              "<leader>ug" = "+git";
              "<leader>w" = "+windows";
            };
      };
    };
  };
}
