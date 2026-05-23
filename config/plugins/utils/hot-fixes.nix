{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    hot-fixes.enable = lib.mkEnableOption "Enable hot-fixes (TODO) modules";
  };
  config = lib.mkIf config.hot-fixes.enable {
    plugins = {
      web-devicons.enable = true;
    };
  };
}
