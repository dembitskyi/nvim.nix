{ config, lib, ... }:
{
  config = lib.mkIf config.ai.minuet.enable {
    plugins.minuet = {
      enable = true;
      settings = {
        provider = "openai_fim_compatible";
        # Debounce ensures request fires after typing stops, so the model sees
        # the full word.
        throttle = 0;
        debounce = 40;
        n_completions = 2;
        context_window = 8000;
        provider_options.openai_fim_compatible = {
          name = "vllm";
          model = "Qwen3.6-35B-A3B";
          end_point = "http://127.0.0.1:5411/v1/completions";
          # llama-swap doesn't check keys, but minuet refuses to run without one.
          api_key.__raw = "function() return 'none' end";
          template = {
            # vLLM's completions API has no `suffix`, so the code below the
            # cursor goes into a comment block above the code before it.
            prompt.__raw = ''
              function(before, after, _)
                local cs = vim.bo.commentstring
                if not cs:find('%s', 1, true) then cs = '-- %s' end
                local left, right = unpack(vim.split(cs, '%s', { plain = true }))
                local function comment(text)
                  return vim.iter(vim.split(text, '\n')):map(function(line)
                    return left .. line .. right
                  end):join('\n')
                end

                local prompt = comment('Continue the following code. Output ONLY code, no explanations.') .. '\n'
                if after and #after > 0 then
                  prompt = prompt .. '\n'
                    .. comment('[CODE BELOW CURSOR (for context, do not repeat):\n' .. after:sub(1, 500) .. '\n]')
                    .. '\n'
                end
                return prompt .. before
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

    plugins.blink-cmp.settings.sources.providers.minuet = {
      name = "minuet";
      module = "minuet.blink";
      async = true;
      timeout_ms = 2000;
      max_items = 4;
      score_offset = 99;

      override.get_completions.__raw = ''
        function(source, ctx, callback)
          -- blink prefetches on InsertEnter; don't wake the LLM before anything is typed.
          if ctx.trigger.kind == 'prefetch' then
            return callback({ items = {}, is_incomplete_forward = true, is_incomplete_backward = true })
          end
          -- minuet marks its results complete, so blink would filter the first
          -- answer instead of asking again; re-query on every keystroke.
          return source:get_completions(ctx, function(response)
            if response then response.is_incomplete_forward = true end
            callback(response)
          end)
        end
      '';

      transform_items.__raw = ''
        function(ctx, items)
          local typed = ctx.line:sub(ctx.bounds.start_col, ctx.cursor[2])
          for _, item in ipairs(items) do
            -- Always show the model's answer, whatever was typed.
            item.filterText = typed
            -- Accepting replaces the typed word. minuet only re-adds it when the
            -- answer starts with a word character, so "printf" + "(...)" would
            -- lose "printf".
            if typed ~= "" and not item.insertText:match('^[%w_-]') then
              item.insertText = typed .. item.insertText
              item.label = typed .. item.label
            end
          end
          return items
        end
      '';
    };
  };
}
