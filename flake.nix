{
  description = "Taminaru dotfiles — Nix flakes + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # The managed user — single source of truth. Defaults to "taminaru";
      # override with TAMINARU_USER=bob (bootstrap/sync export it and pass
      # --impure, since the getEnv read makes flake eval impure).
      username =
        let u = builtins.getEnv "TAMINARU_USER";
        in if u == "" then "taminaru" else u;

      homeConfiguration = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ({ ... }: {
            home.username = username;
            home.homeDirectory = "/home/${username}";
          })
          ./home.nix
        ];
      };
    in {
      homeConfigurations.${username} = homeConfiguration;

      # Default output: apply the configuration
      packages.${system}.default = homeConfiguration.config.home.activationPackage;
    };
}