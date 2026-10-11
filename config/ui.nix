{ lib, ... }:
{
  # Catppuccin Mocha, like the desktop (Hyprland, qutebrowser, sioyek).
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "mocha";
      # Plugins catppuccin doesn't style by default.
      integrations = {
        snacks.enabled = true;
        which_key = true;
      };
    };
  };

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
        # Start menu when nvim opens without a file. Any entry replaces it and
        # it is wiped for good; `i` gives the usual empty buffer in insert mode.
        dashboard = {
          enabled = true;
          preset.keys = [
            {
              icon = " ";
              key = "i";
              desc = "New file";
              action = ":ene | startinsert";
            }
            {
              icon = " ";
              key = "f";
              desc = "Find file";
              action = ":FzfLua files";
            }
            {
              icon = " ";
              key = "r";
              desc = "Recent files";
              action = ":FzfLua oldfiles";
            }
            {
              icon = " ";
              key = "/";
              desc = "Grep";
              action = ":FzfLua live_grep";
            }
            {
              icon = " ";
              key = "q";
              desc = "Quit";
              action = ":qa";
            }
          ];
          sections = [
            {
              section = "keys";
              gap = 1;
            }
          ];
        };
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
