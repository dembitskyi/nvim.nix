{ config, lib, ... }:
{
  config = lib.mkIf config.ai.copilot.enable {
    plugins = {
      # copilot.lua only runs the Copilot language server (`:Copilot auth` to
      # sign in); suggestions are shown by blink through blink-copilot.
      copilot-lua = {
        enable = true;
        settings = {
          suggestion.enabled = false;
          panel.enabled = false;
          filetypes = {
            yaml = false;
            markdown = false;
            json = false;
            help = false;
            gitcommit = false;
            gitrebase = false;
          };
        };
      };
      blink-copilot.enable = true;

      blink-cmp.settings.sources.providers.copilot = {
        name = "copilot";
        module = "blink-copilot";
        async = true;
        timeout_ms = 2000;
        max_items = 4;
        score_offset = 99;
      };
    };
  };
}
