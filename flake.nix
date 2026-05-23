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
          };
          config = lib.mkIf cfg.enable {
            home.packages = [ self.packages.${pkgs.system}.${cfg.profile} ];
          };
        };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = nixpkgsConfig;
        };
        nixvim' = nixvim.legacyPackages.${system};
        mkNvim =
          module:
          nixvim'.makeNixvimWithModule {
            inherit pkgs module;
            extraSpecialArgs = { inherit self; };
          };

        nvims = builtins.mapAttrs (_name: mkNvim) profiles;
      in
      {
        packages = nvims // {
          default = nvims.home;
        };
      }
    );
}
