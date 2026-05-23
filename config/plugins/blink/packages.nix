{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.blink.enable {
    extraPackages = lib.mkIf config.blink.enable (
      with pkgs;
      [
        # blink-cmp-git
        gh
        # blink-cmp-dictionary
        wordnet
        # blink use for gitlab ?
        glab
      ]
    );

    extraPlugins = with pkgs.vimPlugins; [
      blink-cmp-avante
      blink-cmp-conventional-commits
      blink-cmp-npm-nvim
      blink-cmp-yanky
      blink-nerdfont-nvim
    ];
  };
}
