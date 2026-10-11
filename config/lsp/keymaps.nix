{ km, ... }:
let
  # Open warnings+ (or errors only) in the quickfix/location list, one line each.
  diagnosticList =
    key: setlist: title: severity:
    km.lua "n" key ''
      vim.diagnostic.${setlist}({
        open = true,
        title = "${title}",
        severity = ${severity},
        format = function(d)
          local source = d.source and (" [%s]"):format(d.source) or ""
          local code = d.code and (" (%s)"):format(d.code) or ""
          return (d.message:gsub("%s+", " ")) .. source .. code
        end,
      })
    '' title;
  warnings = "{ min = vim.diagnostic.severity.WARN }";
  errors = "vim.diagnostic.severity.ERROR";
in
{
  # Neovim's defaults (K, grn, gra, grr, gri, [d, ]d, ...) stay available.
  keymapsOnEvents.LspAttach = [
    (km.map "n" "<leader>ld" "<cmd>FzfLua lsp_definitions<CR>" "Goto definition")
    (km.map "n" "<leader>li" "<cmd>FzfLua lsp_implementations<CR>" "Goto implementation")
    (km.map "n" "<leader>lt" "<cmd>FzfLua lsp_typedefs<CR>" "Goto type definition")
    (km.map "n" "<leader>lD" "<cmd>FzfLua lsp_references<CR>" "Find references")
    (km.lua "n" "<leader>la" "vim.lsp.buf.code_action()" "Code action")
    (km.lua [ "n" "v" ] "<leader>lf" "require('conform').format({ async = true })" "Format")
    (km.lua "n" "<leader>lx" "vim.lsp.codelens.run()" "Run code lens")

    (km.lua "n" "<leader>lH" "vim.diagnostic.open_float()" "Diagnostic hover")
    (km.lua "n" "<leader>l[" "vim.diagnostic.jump({ count = -1 })" "Previous diagnostic")
    (km.lua "n" "<leader>l]" "vim.diagnostic.jump({ count = 1 })" "Next diagnostic")
    (km.lua "n" "<leader>lQ" "vim.lsp.buf.workspace_diagnostics()" "Workspace diagnostics")
    (diagnosticList "<leader>lE" "setqflist" "Workspace diagnostics list" warnings)
    (diagnosticList "<leader>lW" "setqflist" "Workspace errors list" errors)
    (diagnosticList "<leader>lq" "setloclist" "Buffer diagnostics list" warnings)
    (diagnosticList "<leader>le" "setloclist" "Buffer errors list" errors)

    (km.map "n" "<leader>lI" "<cmd>checkhealth vim.lsp<CR>" "LSP info")
    (km.map "n" "<leader>lX" "<cmd>lsp restart<CR>" "Restart LSP")
  ];
}
