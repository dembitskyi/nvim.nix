{ lib, ... }:
{
  # A centered "hello" instead of the default intro. It is only virtual text
  # over the empty buffer nvim starts with, so `i` edits that buffer as usual;
  # the greeting goes away on insert, any edit, file load or buffer switch.
  autoCmd = [
    {
      event = "VimEnter";
      callback.__raw = ''
        function()
          local buf = vim.api.nvim_get_current_buf()
          local untouched = vim.fn.argc() == 0
            and vim.api.nvim_buf_get_name(buf) == ""
            and vim.api.nvim_buf_line_count(buf) == 1
            and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
          if not untouched then return end

          vim.opt.shortmess:append("I")
          local ns = vim.api.nvim_create_namespace("greeting")
          local function draw()
            local win = vim.fn.bufwinid(buf)
            if win == -1 then return end
            local info = vim.fn.getwininfo(win)[1]
            local text = "hello"
            local lines = {}
            for _ = 2, math.floor(info.height / 2) do table.insert(lines, { { "" } }) end
            local pad = math.max(0, math.floor((info.width - info.textoff - #text) / 2))
            table.insert(lines, { { string.rep(" ", pad) .. text, "Comment" } })
            vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, { id = 1, virt_lines = lines })
          end
          draw()

          local group = vim.api.nvim_create_augroup("greeting", {})
          vim.api.nvim_create_autocmd("VimResized", { group = group, callback = draw })
          vim.api.nvim_create_autocmd({ "InsertEnter", "TextChanged", "BufReadPre", "BufFilePre", "BufLeave" }, {
            group = group,
            buffer = buf,
            once = true,
            callback = function()
              vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
              vim.api.nvim_del_augroup_by_id(group)
            end,
          })
        end
      '';
    }
  ];

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
