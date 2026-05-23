{
  config,
  lib,
  ...
}:
{
  plugins = {
    mini-basics.enable = true;
    mini-bracketed.enable = true;
    mini-align.enable = true;
    mini-icons = {
      enable = true;
      mockDevIcons = true;
    };

    mini-snippets = {
      enable = true;
      settings = {
        snippets = {
          __unkeyed-1.__raw = lib.mkIf config.plugins.friendly-snippets.enable "require('mini.snippets').gen_loader.from_file('${config.plugins.friendly-snippets.package}/snippets/global.json')";
          __unkeyed-2.__raw = "require('mini.snippets').gen_loader.from_lang()";
        };
      };
    };

  };
}
