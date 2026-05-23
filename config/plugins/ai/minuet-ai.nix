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
            name = "Ollama";
            model = "qwen2.5-coder:14b";
            end_point = "http://localhost:11434/v1/completions";
            api_key = "TERM";
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
