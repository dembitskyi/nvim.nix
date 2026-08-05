{
  description = "nvim.nix config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      flake-utils,
      ...
    }:
    let
      profiles = {
        work = import ./config/work.nix;
        home = import ./config/home.nix;
      };

      # Enable unfree packages
      nixpkgsConfig = {
        allowUnfree = true;
      };

      # Build a nixvim package for a given system from a nixvim module.
      # Shared by the per-system `packages` output and the home-manager module
      # (which composes a profile with per-consumer override modules).
      mkNvimFor =
        system: module:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
          };
          nixvim' = nixvim.legacyPackages.${system};
        in
        nixvim'.makeNixvimWithModule {
          inherit pkgs module;
          extraSpecialArgs = { inherit self; };
        };
    in
    {
      nixvimModules = profiles;
      nixvimModule = profiles.home;

      homeModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.nvim-nix;
          # Override module layered on top of the selected profile so consumers
          # can keep a profile (e.g. "home") while independently toggling the
          # AI completion backends. mkForce wins over the profile's own plain
          # `ai.*.enable` assignments.
          aiOverride = {
            ai.minuet.enable = lib.mkForce cfg.ai.minuet.enable;
            ai.copilot.enable = lib.mkForce cfg.ai.copilot.enable;
          };
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
              description = "Which profile to install (home = local LLM via minuet, work = Copilot).";
            };
            ai.minuet.enable = lib.mkOption {
              type = lib.types.bool;
              default = cfg.profile == "home";
              description = "Enable the minuet AI (local LLM) completion source. Defaults on for the home profile; set false to keep the home profile without the local LLM completion.";
            };
            ai.copilot.enable = lib.mkOption {
              type = lib.types.bool;
              default = cfg.profile == "work";
              description = "Enable the GitHub Copilot completion source. Defaults on for the work profile.";
            };
          };
          config = lib.mkIf cfg.enable {
            home.packages = [
              (mkNvimFor pkgs.stdenv.hostPlatform.system {
                imports = [
                  profiles.${cfg.profile}
                  aiOverride
                ];
              })
            ];
          };
        };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        nvims = builtins.mapAttrs (_name: module: mkNvimFor system module) profiles;
      in
      {
        packages = nvims // {
          default = nvims.home;
        };
      }
    );
}
