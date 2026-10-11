{
  description = "nvim.nix config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nixvim, ... }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # home = local LLM completion via minuet, work = GitHub Copilot. minuet
      # is opt-in (ai.minuet.enable): its first insert-mode keystroke makes
      # llama-swap start a model, so a plain `nix run` or test build must not
      # wake the GPU.
      profiles = {
        home = {
          imports = [ ./config ];
        };
        work = {
          imports = [ ./config ];
          ai.copilot.enable = lib.mkDefault true;
        };
      };

      mkNvim =
        system: module:
        nixvim.legacyPackages.${system}.makeNixvimWithModule {
          inherit module;
          # copilot-language-server is unfree.
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        };
    in
    {
      nixvimModules = profiles;

      homeModules.default =
        { config, pkgs, ... }:
        let
          cfg = config.programs.nvim-nix;
        in
        {
          options.programs.nvim-nix = {
            enable = lib.mkEnableOption "nvim.nix";
            profile = lib.mkOption {
              type = lib.types.enum [
                "home"
                "work"
              ];
              default = "home";
              description = "Which profile to install (home = local LLM via minuet, opt-in; work = Copilot).";
            };
            ai.minuet.enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable the minuet AI (local LLM) completion source. Off by default: typing in insert mode makes the model server start a model.";
            };
            ai.copilot.enable = lib.mkOption {
              type = lib.types.bool;
              default = cfg.profile == "work";
              description = "Enable the GitHub Copilot completion source. Defaults on for the work profile.";
            };
          };

          config = lib.mkIf cfg.enable {
            home.packages = [
              (mkNvim pkgs.stdenv.hostPlatform.system {
                imports = [ profiles.${cfg.profile} ];
                ai = { inherit (cfg.ai) minuet copilot; };
              })
            ];
          };
        };

      packages = lib.genAttrs systems (
        system:
        let
          nvims = lib.mapAttrs (_: mkNvim system) profiles;
        in
        nvims // { default = nvims.home; }
      );
    };
}
