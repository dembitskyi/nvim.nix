{ km, ... }:
let
  # In diff mode keep the builtin ]c/[c, otherwise jump between hunks.
  navHunk = key: direction: {
    mode = "n";
    inherit key;
    action.__raw = ''
      function()
        if vim.wo.diff then return '${key}' end
        vim.schedule(function() require('gitsigns').nav_hunk('${direction}') end)
        return '<Ignore>'
      end
    '';
    options = {
      expr = true;
      desc = "${direction} hunk";
    };
  };
  gs =
    mode: key: cmd: desc:
    km.map mode key "<cmd>Gitsigns ${cmd}<CR>" desc;
in
{
  plugins = {
    gitsigns = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        current_line_blame = true;
        current_line_blame_opts = {
          delay = 500;
          ignore_whitespace = true;
        };
      };
    };

    lazygit.enable = true;
  };

  keymaps = [
    (navHunk "]c" "next")
    (navHunk "[c" "prev")

    (gs "n" "<leader>gS" "stage_buffer" "Stage buffer")
    (gs "n" "<leader>gU" "reset_buffer_index" "Unstage buffer")
    (gs "n" "<leader>gR" "reset_buffer" "Reset buffer")

    # stage_hunk on an already staged hunk unstages it.
    (gs "n" "<leader>ghs" "stage_hunk" "Stage/unstage hunk")
    (km.lua "v" "<leader>ghs" "require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })"
      "Stage/unstage selection"
    )
    (gs "n" "<leader>ghr" "reset_hunk" "Reset hunk")
    (km.lua "v" "<leader>ghr" "require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })"
      "Reset selection"
    )
    (gs [ "n" "v" ] "<leader>ghp" "preview_hunk" "Preview hunk")
    (gs "n" "<leader>ghi" "preview_hunk_inline" "Preview hunk inline")
    (gs "n" "<leader>ghq" "setqflist" "Hunks to quickfix")
    (gs "n" "<leader>ghQ" "setqflist all" "All hunks to quickfix")
    (gs [ "o" "x" ] "ih" "select_hunk" "Select hunk")

    (gs "n" "<leader>ugb" "toggle_current_line_blame" "Toggle blame")
    (gs "n" "<leader>ugw" "toggle_word_diff" "Toggle word diff")

    (km.map "n" "<leader>gg" "<cmd>LazyGit<CR>" "LazyGit")
    (km.lua "n" "<leader>gb" "Snacks.picker.git_log_line()" "Git log for line")
    (km.lua "n" "<leader>gL" "Snacks.picker.git_log()" "Git log (cwd)")
    (km.lua "n" "<leader>gf" "Snacks.picker.git_log_file()" "Git log for file")
    (km.lua [ "n" "x" ] "<leader>gB" "Snacks.gitbrowse()" "Open in browser")
  ];
}
