{ km, ... }:
let
  # Jump by display lines, but add counted jumps (5j) to the jumplist.
  jumpMotion = key: {
    mode = "n";
    inherit key;
    action.__raw = "[[(v:count > 1 ? 'm`' . v:count : 'g') . '${key}']]";
    options = {
      expr = true;
      desc = "Move by display line; counted jumps go to the jumplist";
    };
  };
in
{
  keymaps =
    map (key: km.map "n" key "<Nop>" "Disabled") [
      "<Up>"
      "<Down>"
      "<Left>"
      "<Right>"
    ]
    ++ [
      (jumpMotion "j")
      (jumpMotion "k")

      # Tabs
      (km.map "n" "<leader><tab><tab>" "<cmd>tabnew<cr>" "New tab")
      (km.map "n" "<leader><tab>d" "<cmd>tabclose<cr>" "Close tab")
      (km.map "n" "<leader><tab>]" "<cmd>tabnext<cr>" "Next tab")
      (km.map "n" "<leader><tab>[" "<cmd>tabprevious<cr>" "Previous tab")
      (km.map "n" "<leader><tab>f" "<cmd>tabfirst<cr>" "First tab")
      (km.map "n" "<leader><tab>l" "<cmd>tablast<cr>" "Last tab")

      # Windows
      (km.map "n" "<leader>ww" "<C-w>p" "Other window")
      (km.map "n" "<leader>wd" "<C-w>c" "Delete window")
      (km.map "n" "<leader>w-" "<C-w>s" "Split window below")
      (km.map "n" "<leader>w|" "<C-w>v" "Split window right")

      (km.map "n" "<leader>qq" "<cmd>quitall<cr>" "Quit all")

      # Toggles
      (km.lua "n" "<leader>ul" "Snacks.toggle.line_number():toggle()" "Toggle line numbers")
      (km.lua "n" "<leader>uL" "Snacks.toggle.option('relativenumber'):toggle()"
        "Toggle relative line numbers"
      )
      (km.lua "n" "<leader>uw" "Snacks.toggle.option('wrap'):toggle()" "Toggle line wrap")
      (km.lua "n" "<leader>uh" "Snacks.toggle.inlay_hints():toggle()" "Toggle inlay hints")
      (km.lua "n" "<leader>ud" "Snacks.toggle.diagnostics():toggle()" "Toggle diagnostics")

      # Editing
      (km.map "v" "J" ":m '>+1<CR>gv=gv" "Move selection down")
      (km.map "v" "K" ":m '<-2<CR>gv=gv" "Move selection up")
      (km.map "n" "J" "mzJ`z" "Join lines, keep cursor")
      (km.map "v" "<" "<gv" "Indent left, keep selection")
      (km.map "v" ">" ">gv" "Indent right, keep selection")
      (km.map "x" "<leader>p" ''"_dP'' "Paste over without yanking")
      (km.map [ "n" "v" ] "<leader>y" ''"+y'' "Copy to system clipboard")
      (km.map [ "n" "v" ] "<leader>Y" ''"+Y'' "Copy to system clipboard")
      (km.map [ "n" "v" ] "<leader>D" ''"_d'' "Delete to void register")
      (km.map "i" "<C-c>" "<Esc>" "Escape")

      # Keep the cursor centered
      (km.map "n" "<C-d>" "<C-d>zz" "Half page down")
      (km.map "n" "<C-u>" "<C-u>zz" "Half page up")
      (km.map "n" "n" "nzzzv" "Next match")
      (km.map "n" "N" "Nzzzv" "Previous match")

      (km.map "n" "<Esc>" "<cmd>nohlsearch<CR>" "Clear search highlight")
    ];
}
