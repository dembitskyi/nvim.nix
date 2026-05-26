{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    ai.minuet.enable = lib.mkEnableOption "Enable minuet AI (local LLM) module";
  };
  config = lib.mkIf config.ai.minuet.enable {
    plugins.minuet = {
      enable = true;
      # Patch: 1) set is_incomplete_forward=true so blink re-queries on each
      # keystroke, 2) add filterText to items so blink always shows them
      # regardless of fuzzy matching against the current keyword,
      # 3) fix prepend_to_complete_word to prepend when completion starts with
      # a non-word character (e.g., model returns "(" after typing "printf").
      package = pkgs.vimPlugins.minuet-ai-nvim.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace lua/minuet/blink.lua \
            --replace-fail 'is_incomplete_forward = false' 'is_incomplete_forward = true'
          substituteInPlace lua/minuet/blink.lua \
            --replace-fail \
              'label = item_label,' \
              'label = item_label, filterText = ctx.line:sub(ctx.bounds.start_col, ctx.cursor[2]),'
          substituteInPlace lua/minuet/utils.lua \
            --replace-fail \
              'if last_word_b and first_word_a and not first_word_a:find(last_word_b, 1, true) then' \
              'if last_word_b and (not first_word_a or not first_word_a:find(last_word_b, 1, true)) then'
        '';
      });
      settings = {
        provider = "openai_fim_compatible";
        # Debounce ensures request fires after typing stops, so the model sees
        # the full word. Blink caches results within a word boundary, so
        # debounce=0 would only ever send the first character.
        throttle = 0;
        debounce = 40;
        # notify = "debug";
        n_completions = 2;
        context_window = 8000;
        provider_options = {
          openai_fim_compatible = {
            name = "vllm";
            model = "Qwen3.6-35B-A3B";
            end_point = "http://127.0.0.1:5411/v1/completions";
            api_key = "TERM";
            template = {
              prompt.__raw = ''
                function(before, after, _)
                  local header = "-- Continue the following code. Output ONLY code, no explanations.\n"
                  local after_ctx = ""
                  if after and #after > 0 then
                    local snippet = after:sub(1, 500):gsub("\n", "\n-- ")
                    after_ctx = "\n-- [CODE BELOW CURSOR (for context, do not repeat):\n-- " .. snippet .. "\n-- ]\n"
                  end
                  return header .. after_ctx .. before
                end
              '';
              suffix = false;
            };
            optional = {
              max_tokens = 100;
              top_p = 0.9;
              temperature = 0.6;
            };
          };
        };
      };
    };
  };
}
