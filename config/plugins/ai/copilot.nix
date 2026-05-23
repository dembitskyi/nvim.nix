{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    ai.copilot.enable = lib.mkEnableOption "Enable copilot module";
  };
  config = lib.mkIf config.ai.copilot.enable {
    extraPlugins = lib.optionals config.plugins.copilot-lua.enable (
      with pkgs.vimPlugins;
      lib.optionals config.plugins.lualine.enable [
        copilot-lualine
      ]
    );

    plugins = {
      copilot-lua = {
        enable = true;
        lazyLoad.settings.event = [ "InsertEnter" ];

        settings = {
          suggestion = {
            enabled = false;
            auto_trigger = true;
            keymap = {
              accept = "<C-y>";
              accept_word = "<M-w>";
              accept_line = "<M-e>";
              next = "<M-]>";
              prev = "<M-[>";
              dismiss = "<C-n>";
            };
          };

          panel = {
            enabled = false;
            auto_refresh = true;
            keymap = {
              jump_prev = "[[";
              jump_next = "]]";
              accept = "<cr>";
              refresh = "gr";
              open = "<M-CR>";
            };
            layout = {
              position = "bottom";
              ratio = 0.4;
            };
          };

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
    };

    keymaps = lib.mkIf config.plugins.copilot-chat.enable [
      {
        mode = "n";
        key = "<leader>aCa";
        action = "<cmd>CopilotChatAgents<CR>";
        options = {
          desc = "List Available Agents";
        };
      }
      {
        mode = "n";
        key = "<leader>aCc";
        action = "<cmd>CopilotChatClose<CR>";
        options.desc = "Close Chat";
      }
      {
        mode = "n";
        key = "<leader>aCl";
        action = "<cmd>CopilotChatLoad<CR>";
        options = {
          desc = "Load Chat History";
        };
      }
      {
        mode = "n";
        key = "<leader>aCm";
        action = "<cmd>CopilotChatModels<CR>";
        options = {
          desc = "List Available Models";
        };
      }
      {
        mode = "n";
        key = "<leader>aCo";
        action = "<cmd>CopilotChatOpen<CR>";
        options.desc = "Open Chat";
      }
      {
        mode = "n";
        key = "<leader>aCp";
        action.__raw = ''
          function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
          end
        '';
        options = {
          desc = "Prompt Actions";
        };
      }
      {
        mode = "n";
        key = "<leader>aCP";
        action = "<cmd>CopilotChatPrompts<CR>";
        options.desc = "Select Prompt";
      }

      {
        mode = "n";
        key = "<leader>aCq";
        action.__raw = ''
          function()
            local input = vim.fn.input("Quick Chat: ")
            if input ~= "" then
              require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
            end
          end
        '';
        options = {
          desc = "Quick Chat";
        };
      }
      {
        mode = "n";
        key = "<leader>aCs";
        action = "<cmd>CopilotChatStop<CR>";
        options.desc = "Stop Chat";
      }
      {
        mode = "n";
        key = "<leader>aCS";
        action = "<cmd>CopilotChatSave<CR>";
        options.desc = "Save Chat";
      }
      {
        mode = "n";
        key = "<leader>aCr";
        action = "<cmd>CopilotChatReset<CR>";
        options.desc = "Reset Chat";
      }
      {
        mode = "n";
        key = "<leader>aCt";
        action = "<cmd>CopilotChatToggle<CR>";
        options = {
          desc = "Toggle Chat Window";
        };
      }
    ];
  };
}
