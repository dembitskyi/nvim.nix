{ config, ... }:
{
  plugins = {
    lsp = {
      # ccls documentation
      # See: https://github.com/MaskRay/ccls
      servers = {
        ccls = {
          enable = true;
          initOptions.compilationDatabaseDirectory = "build";
        };
      };
    };
  };
}
