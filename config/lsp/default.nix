{ pkgs, ... }:
let
  proseFiletypes = [
    "markdown"
    "text"
    "gitcommit"
    "gitrebase"
    "mail"
  ];
in
{
  imports = [ ./keymaps.nix ];

  plugins = {
    lspconfig.enable = true;
    # Filetype detection for Helm templates, so helm_ls attaches.
    helm.enable = true;
  };

  lsp = {
    inlayHints.enable = true;

    servers = {
      bashls.enable = true;
      biome = {
        enable = true;
        config.filetypes = [
          "javascript"
          "javascriptreact"
          "typescript"
          "typescriptreact"
          "json"
          "jsonc"
          "css"
          "html"
        ];
      };
      clangd = {
        enable = true;
        config = {
          cmd = [
            "clangd"
            "--background-index"
            "--clang-tidy"
            "--header-insertion=iwyu"
            "--completion-style=detailed"
            "--function-arg-placeholders"
            "--fallback-style=llvm"
          ];
          init_options = {
            usePlaceholders = true;
            completeUnimported = true;
            clangdFileStatus = true;
          };
        };
      };
      cmake.enable = true;
      cssls.enable = true;
      docker_language_server.enable = true;
      eslint = {
        enable = true;
        config.settings = {
          # Formatting stays with conform/biome; ESLint only for diagnostics and fixes.
          format = false;
          # Fallback for projects without a local ESLint install.
          nodePath = "${pkgs.eslint}/lib/node_modules";
        };
      };
      fish_lsp.enable = true;
      gopls.enable = true;
      harper_ls = {
        enable = true;
        config = {
          filetypes = proseFiletypes;
          settings.harper-ls = {
            linters = {
              boring_words = true;
              linking_verbs = true;
              # Rarely useful with coding
              sentence_capitalization = false;
              spell_check = false;
            };
            codeActions.forceStable = true;
          };
        };
      };
      helm_ls.enable = true;
      html.enable = true;
      hyprls.enable = true;
      jsonls.enable = true;
      kulala_ls.enable = true;
      lua_ls.enable = true;
      marksman.enable = true;
      nixd.enable = true;
      nushell.enable = pkgs.stdenv.hostPlatform.isLinux;
      pyright.enable = true;
      ruff.enable = true;
      rust_analyzer = {
        enable = true;
        config.settings = {
          cargo.features = "all";
          check = {
            command = "clippy";
            features = "all";
          };
          diagnostics.styleLints.enable = true;
          files.excludeDirs = [ ".direnv" ];
          inlayHints = {
            bindingModeHints.enable = true;
            closureStyle = "rust_analyzer";
            closureReturnTypeHints.enable = "always";
            discriminantHints.enable = "always";
            expressionAdjustmentHints.enable = "always";
            implicitDrops.enable = true;
            lifetimeElisionHints.enable = "always";
            rangeExclusiveHints.enable = true;
          };
          rustc.source = "discover";
        };
      };
      sqls.enable = true;
      statix.enable = true;
      stylelint_lsp = {
        enable = true;
        # Only attach in projects that actually use stylelint.
        config.workspace_required = true;
      };
      tailwindcss = {
        enable = true;
        config.filetypes = [
          "css"
          "scss"
          "sass"
          "html"
          "javascriptreact"
          "typescriptreact"
          "vue"
          "svelte"
        ];
      };
      taplo.enable = true;
      ts_ls.enable = true;
      typos_lsp = {
        enable = true;
        config = {
          filetypes = proseFiletypes;
          init_options.diagnosticSeverity = "Hint";
        };
      };
      yamlls.enable = true;
    };
  };
}
