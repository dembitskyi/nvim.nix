{
  lib,
  config,
  ...
}:
{
  options = {
    ai.minuet.enable = lib.mkEnableOption "Enable minuet AI (local LLM) module";
  };
  config = lib.mkIf config.ai.minuet.enable {
    plugins.minuet = {
      enable = true;
      settings = {
        provider = "openai_fim_compatible";
        context_window = 512;
        provider_options = {
          openai_fim_compatible = {
            name = "vllm";
            model = "Qwen3.6-35B-A3B";
            end_point = "http://127.0.0.1:5411/v1/completions";
            api_key = "TERM";
            template = {
              prompt.__raw = ''
                function(before, after, _)
                  return '<|fim_prefix|>' .. before .. '<|fim_suffix|>' .. after .. '<|fim_middle|>'
                end
              '';
              suffix = false;
            };
            optional = {
              max_tokens = 100;
              top_p = 0.9;
            };
          };
        };
      };
    };
  };
}
