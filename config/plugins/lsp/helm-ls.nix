{ config, ... }:
{
  autoCmd = [
    {
      event = "FileType";
      pattern = "helm";
      command = "lsp restart";
    }
  ];

  lsp = {
    # helm-ls documentation
    # See: https://github.com/mrjosh/helm-ls
    servers = {
      helm_ls.enable = true;
    };
  };

  plugins = {
    helm = {
      inherit (config.plugins.lsp) enable;
    };
  };
}
