{ km, pkgs, ... }:
let
  fzf =
    key: cmd: desc:
    km.map "n" key "<cmd>FzfLua ${cmd}<CR>" desc;
in
{
  plugins.fzf-lua = {
    enable = true;
    lazyLoad.settings.cmd = "FzfLua";
    settings = {
      oldfiles.cwd_only = true;
      winopts.preview = {
        default = "bat";
        horizontal = "up:70%";
      };
    };
  };

  extraPackages = [ pkgs.bat ];

  keymaps = [
    (fzf "<leader>ff" "files winopts.preview.hidden=true" "Find files")
    (fzf "<leader>fo" "oldfiles" "Find old files")
    (fzf "<leader>fb" "buffers" "Find buffers")
    (fzf "<leader>f/" "blines" "Fuzzy find in current buffer")
    (fzf "<leader>f?" "lines" "Fuzzy find in open buffers")
    (fzf "<leader>f<CR>" "resume" "Resume find")
    (fzf "<leader>f'" "marks" "Find marks")
    (fzf "<leader>fa" "autocmds" "Find autocmds")
    (fzf "<leader>fc" "commands" "Find commands")
    (fzf "<leader>fd" "diagnostics_document" "Find buffer diagnostics")
    (fzf "<leader>fD" "diagnostics_workspace" "Find workspace diagnostics")
    (fzf "<leader>fh" "helptags" "Find help tags")
    (fzf "<leader>fk" "keymaps" "Find keymaps")
    (fzf "<leader>fm" "manpages" "Find man pages")
    (fzf "<leader>fq" "quickfix" "Find quickfix")
    (fzf "<leader>fr" "registers" "Find registers")
    (fzf "<leader>fS" "spell_suggest" "Find spelling suggestions")
    (fzf "<leader>fT" "colorschemes" "Find theme")
    (fzf "<leader>gs" "git_status" "Find git status")
    (km.map [ "n" "v" ] "<leader>sw" "<cmd>FzfLua grep_cword<CR>" "Find word")
    (km.lua "n" "<leader>/" "require('fzf-lua').live_grep({ fzf_cli_args = '-i' })" "Live grep")
  ];
}
