{ config, ... }:
let
  mkBlinkPlugin =
    {
      enable ? true,
      ...
    }@args:
    {
      inherit enable;
      lazyLoad.settings.event = [
        "InsertEnter"
        "CmdlineEnter"
      ];
    }
    // (builtins.removeAttrs args [ "enable" ]);
in
{
  plugins = {
    # keep-sorted start block=yes
    blink-cmp-dictionary = mkBlinkPlugin {
      enable = false;
    };
    blink-cmp-git = mkBlinkPlugin { };
    blink-cmp-spell = mkBlinkPlugin { };
    blink-cmp-words = mkBlinkPlugin {
      enable = true;
    };
    blink-copilot = mkBlinkPlugin {
      enable = config.ai.copilot.enable;
    };
    blink-emoji = mkBlinkPlugin { };
    blink-ripgrep = mkBlinkPlugin { };
    # keep-sorted end
  };
}
