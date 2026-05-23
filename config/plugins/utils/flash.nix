{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    flash.enable = lib.mkEnableOption "Enable flash module";
  };
  config = lib.mkIf config.flash.enable {
    plugins = {
      flash = {
        enable = true;
      };
    };
    keymaps = lib.mkIf config.flash.enable [
      {
        key = "s";
        action.__raw = ''function() require("flash").jump() end'';
        mode = [
          "n"
          "x"
          "o"
        ];
        options.desc = "Flash";
      }
    ];
  };
}
