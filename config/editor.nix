{ km, ... }:
{
  plugins = {
    flash.enable = true;

    markdown-preview = {
      enable = true;
      settings = {
        browser = "firefox";
        theme = "dark";
      };
    };

    # Format on save and `gq`. Filetypes without a formatter listed here use
    # the attached LSP servers' formatting.
    conform-nvim = {
      enable = true;
      autoInstall.enable = true;
      settings = {
        formatters_by_ft.nix = [ "nixfmt" ];
        default_format_opts.lsp_format = "fallback";
        format_on_save.timeout_ms = 1000;
      };
    };
  };

  opts.formatexpr = "v:lua.require'conform'.formatexpr()";

  keymaps = [
    (km.lua [ "n" "x" "o" ] "s" "require('flash').jump()" "Flash")
    (km.map "n" "<leader>cp" "<cmd>MarkdownPreview<cr>" "Markdown preview")
  ];
}
