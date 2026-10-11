{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Sources for code buffers. Providers with an `enabled` function below
  # (dictionary, thesaurus, npm) decide per filetype themselves; the AI
  # providers are defined in ../ai.
  codeSources = [
    "lsp"
    "path"
    "snippets"
    "buffer"
    "dictionary"
    "emoji"
    "nerdfont"
    "npm"
    "ripgrep"
    "spell"
    "thesaurus"
  ]
  ++ lib.optional config.ai.copilot.enable "copilot"
  ++ lib.optional config.ai.minuet.enable "minuet";

  proseSources = [
    "buffer"
    "spell"
    "dictionary"
    "thesaurus"
  ];

  proseFiletypes.__raw = ''
    function()
      return vim.tbl_contains({ 'markdown', 'text', 'gitcommit', 'scratch' }, vim.bo.filetype)
    end
  '';

  # blink-cmp-git calls the forge CLI for issues/PRs/mentions. Without a login
  # every call fails with an error popup, so only enable a forge's features
  # when its CLI is authenticated. `enable` runs inside the plugin's coroutine,
  # so the check doesn't block.
  forgeFeatures =
    forge: authCmd:
    lib.genAttrs [ "issue" "pull_request" "mention" ] (_: {
      enable.__raw = ''
        function()
          if vim.fn.executable('${lib.head authCmd}') ~= 1 then return false end
          local co = coroutine.running()
          vim.system(${lib.nixvim.toLuaObject authCmd}, { text = true }, vim.schedule_wrap(function(out)
            coroutine.resume(co, out)
          end))
          return coroutine.yield().code == 0 and require('blink-cmp-git.default.${forge}').issue.enable()
        end
      '';
    });
in
{
  plugins = {
    blink-cmp-git.enable = true;
    blink-cmp-spell.enable = true;
    blink-cmp-words.enable = true;
    blink-emoji.enable = true;
    blink-ripgrep.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    blink-cmp-conventional-commits
    blink-cmp-npm-nvim
    blink-nerdfont-nvim
  ];

  # Forge CLIs for blink-cmp-git.
  extraPackages = with pkgs; [
    gh
    glab
  ];

  plugins.blink-cmp.settings.sources = {
    default.__raw = ''
      function()
        local ok, node = pcall(vim.treesitter.get_node)
        if ok and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
          return ${lib.nixvim.toLuaObject proseSources}
        end
        if vim.bo.filetype == 'gitcommit' then
          return ${
            lib.nixvim.toLuaObject (
              proseSources
              ++ [
                "git"
                "conventional_commits"
              ]
            )
          }
        end
        return ${lib.nixvim.toLuaObject codeSources}
      end
    '';

    providers = {
      buffer = {
        score_offset = 45;
        min_keyword_length = 2;
        max_items = 15;
        # All normal buffers, or only the current one (<leader>ucb).
        opts.get_bufnrs.__raw = ''
          function()
            if not vim.g.blink_buffer_all_buffers then return { vim.api.nvim_get_current_buf() } end
            return vim.tbl_filter(function(bufnr)
              return vim.bo[bufnr].buftype == ""
            end, vim.api.nvim_list_bufs())
          end
        '';
      };

      lsp = {
        score_offset = 60;
        fallbacks = [ ]; # Show buffer items alongside LSP ones
        transform_items.__raw = ''
          function(_, items)
            return vim.tbl_filter(function(item)
              return item.kind ~= require('blink.cmp.types').CompletionItemKind.Keyword
            end, items)
          end
        '';
      };

      path = {
        score_offset = 55;
        # Relative to the buffer's directory, or to cwd (<leader>ucp).
        opts.get_cwd.__raw = ''
          function(context)
            local bufpath = vim.api.nvim_buf_get_name(context.bufnr)
            if vim.g.blink_path_from_cwd or bufpath == "" then return vim.fn.getcwd() end
            return vim.fn.fnamemodify(bufpath, ":p:h")
          end
        '';
      };

      snippets = {
        score_offset = 60;
        should_show_items.__raw = ''
          function(ctx)
            return ctx.trigger.initial_kind ~= 'trigger_character'
          end
        '';
      };

      conventional_commits = {
        name = "Conventional Commits";
        module = "blink-cmp-conventional-commits";
        score_offset = 68;
      };

      dictionary = {
        name = "Dict";
        module = "blink-cmp-words.dictionary";
        min_keyword_length = 3;
        max_items = 8;
        score_offset = 8;
        enabled = proseFiletypes;
        opts = {
          dictionary_search_threshold = 3;
          definition_pointers = [
            "!"
            "&"
            "^"
          ];
        };
      };

      emoji = {
        name = "Emoji";
        module = "blink-emoji";
        score_offset = 10;
      };

      git = {
        name = "Git";
        module = "blink-cmp-git";
        score_offset = 70;
        should_show_items.__raw = ''
          function()
            return vim.o.filetype == 'gitcommit' or vim.o.filetype == 'markdown'
          end
        '';
        opts.git_centers = {
          github = forgeFeatures "github" [
            "gh"
            "auth"
            "token"
          ];
          gitlab = forgeFeatures "gitlab" [
            "glab"
            "auth"
            "status"
          ];
        };
      };

      nerdfont = {
        name = "Nerd Fonts";
        module = "blink-nerdfont";
        score_offset = 68;
        opts.insert = true;
      };

      npm = {
        name = "npm";
        module = "blink-cmp-npm";
        async = true;
        timeout_ms = 2000;
        score_offset = 70;
        enabled.__raw = ''
          function()
            return vim.fn.expand('%:t') == 'package.json'
          end
        '';
        opts = {
          ignore = [ ];
          only_semantic_versions = true;
          only_latest_version = false;
        };
      };

      ripgrep = {
        name = "Ripgrep";
        module = "blink-ripgrep";
        async = true;
        timeout_ms = 500;
        max_items = 10;
        min_keyword_length = 4;
        score_offset = 5;
      };

      spell = {
        name = "Spell";
        module = "blink-cmp-spell";
        max_items = 3;
        score_offset = 15;
      };

      thesaurus = {
        name = "Thesaurus";
        module = "blink-cmp-words.thesaurus";
        min_keyword_length = 3;
        max_items = 8;
        score_offset = 10;
        enabled = proseFiletypes;
        opts = {
          definition_pointers = [
            "!"
            "&"
            "^"
          ];
          similarity_pointers = [
            "&"
            "^"
          ];
          similarity_depth = 2;
        };
      };
    };
  };
}
