{
  globals.mapleader = " ";

  # mini.basics sets more defaults (mouse, undofile, linebreak, ...) for
  # anything not set here.
  opts = {
    number = true;
    relativenumber = true;
    signcolumn = "yes";
    cursorline = true;
    colorcolumn = "80";
    scrolloff = 8;
    wrap = false;
    breakindent = true;
    showmode = true;
    showtabline = 2;
    cmdheight = 2;
    laststatus = 3;
    termguicolors = true;

    # 2-space indentation
    tabstop = 2;
    softtabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    smartindent = true;
    copyindent = true;
    preserveindent = true;
    formatoptions = "rqnl1j";
    formatlistpat = "^\\s*[0-9\\-\\+\\*]\\+[\\.)]*\\s\\+";

    ignorecase = true;
    smartcase = true;
    inccommand = "split";
    grepprg = "rg --vimgrep";
    grepformat = "%f:%l:%c:%m";

    splitbelow = true;
    splitright = true;

    swapfile = false;
    undofile = true;
    updatetime = 50;
    timeoutlen = 200;

    # Folds come from treesitter (ui.nix); start with everything open.
    foldlevelstart = 99;

    # Shown when 'list' is toggled (`\l`, from mini.basics).
    listchars = "eol:↲,tab:|->,lead:·,space: ,trail:•,extends:→,precedes:←,nbsp:␣";

    guicursor = [
      "n-v-c-i-ci-ve:block"
      "r-cr:hor20"
      "o:hor50"
      "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"
      "sm:block-blinkwait175-blinkoff150-blinkon175"
    ];
  };
}
