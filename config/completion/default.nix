{ km, lib, ... }:
let
  # <A-1> .. <A-9>, <A-0> accept the n-th item.
  acceptByIndex = lib.listToAttrs (
    map (i: {
      name = "<A-${toString (lib.mod i 10)}>";
      value = [ { __raw = "function(cmp) cmp.accept({ index = ${toString i} }) end"; } ];
    }) (lib.range 1 10)
  );

  toggle = var: desc: ''
    vim.g.${var} = not vim.g.${var}
    vim.notify("${desc}: " .. (vim.g.${var} and "on" or "off"))
  '';
in
{
  imports = [ ./sources.nix ];

  # Read by the menu columns and the buffer/path providers; flipped by <leader>uc*.
  globals = {
    blink_show_item_idx = true;
    blink_buffer_all_buffers = true;
    blink_path_from_cwd = false;
  };

  plugins.blink-cmp = {
    enable = true;
    lazyLoad.settings.event = [
      "InsertEnter"
      "CmdlineEnter"
    ];
    settings = {
      keymap = acceptByIndex // {
        preset = "enter";
        "<C-.>" = [
          "show"
          "show_documentation"
          "hide_documentation"
        ];
        "<C-y>" = [
          "select_and_accept"
          "fallback"
        ];
      };

      cmdline = {
        keymap = acceptByIndex // {
          preset = "cmdline";
          "<Left>" = false;
          "<Right>" = false;
          "<Up>" = [
            "select_prev"
            "fallback"
          ];
          "<Down>" = [
            "select_next"
            "fallback"
          ];
        };
        completion = {
          list.selection.preselect = false;
          menu.auto_show = true;
        };
      };

      completion = {
        keyword.range = "full";
        trigger = {
          prefetch_on_insert = true;
          show_on_backspace = true;
        };
        ghost_text.enabled = true;
        accept.auto_brackets.override_brackets_for_filetypes = {
          lua = [
            "{"
            "}"
          ];
          nix = [
            "{"
            "}"
          ];
        };
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 25;
          window.border = "rounded";
        };
        list.selection = {
          auto_insert = false;
          preselect = false;
        };
        menu = {
          border = "rounded";
          # Keep a menu that opened upwards (multi-line items) upwards until it closes.
          direction_priority.__raw = ''
            function()
              local ctx = require('blink.cmp').get_context()
              local item = require('blink.cmp').get_selected_item()
              if ctx == nil or item == nil then return { 's', 'n' } end

              local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
              if item_text:find('\n') ~= nil or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
                vim.g.blink_cmp_upwards_ctx_id = ctx.id
                return { 'n', 's' }
              end
              return { 's', 'n' }
            end
          '';
          draw = {
            snippet_indicator = "◦";
            treesitter = [ "lsp" ];
            columns.__raw = ''
              function()
                local columns = { { "label" }, { "kind_icon", "kind", gap = 1 }, { "source_name", gap = 1 } }
                if vim.g.blink_show_item_idx then table.insert(columns, 1, { "item_idx" }) end
                return columns
              end
            '';
            components = {
              item_idx = {
                text.__raw = "function(ctx) return ctx.idx == 10 and '0' or ctx.idx > 10 and ' ' or tostring(ctx.idx) end";
                highlight = "BlinkCmpItemIdx";
              };
              # mini.icons for LSP kinds; kinds it doesn't know (Copilot, ...) fall
              # back to appearance.kind_icons.
              kind_icon = {
                ellipsis = false;
                text.__raw = ''
                  function(ctx)
                    local icon, _, is_default = require('mini.icons').get('lsp', ctx.kind)
                    if is_default then
                      return require('blink.cmp.config').appearance.kind_icons[ctx.kind] or icon
                    end
                    return icon
                  end
                '';
                highlight.__raw = ''
                  function(ctx)
                    local _, hl = require('mini.icons').get('lsp', ctx.kind)
                    return hl
                  end
                '';
              };
            };
          };
        };
      };

      appearance.kind_icons = {
        Copilot = "";
        Text = "";
        Field = "";
        Variable = "";
        Class = "";
        Interface = "";
        TypeParameter = "";
      };

      snippets.preset = "mini_snippets";
    };
  };

  keymaps = [
    # blink skips buffers with vim.b.completion == false.
    (km.lua "n" "<leader>uca" ''
      vim.b.completion = vim.b.completion == false
      vim.notify("Completion (buffer): " .. (vim.b.completion and "on" or "off"))
    '' "Toggle completion (buffer)")
    (km.lua "n" "<leader>uci" (toggle "blink_show_item_idx" "Completion item index")
      "Toggle completion item index"
    )
    (km.lua "n" "<leader>ucp" (toggle "blink_path_from_cwd" "Path completion from cwd")
      "Toggle path completion from cwd"
    )
    (km.lua "n" "<leader>ucb" (toggle "blink_buffer_all_buffers" "Buffer completion from all buffers")
      "Toggle buffer completion from all buffers"
    )
  ];
}
