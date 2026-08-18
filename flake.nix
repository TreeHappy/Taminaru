{
  description = "Taminaru dotfiles — Nix flakes + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mammouth is not in nixpkgs — use third-party flake
    mammouth.url = "github:FirPic/mammouth-code-nix";
  };

  outputs = { nixpkgs, home-manager, mammouth, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.taminaru = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Pass extraSpecialArgs so home.nix can access mammouth
        extraSpecialArgs = {
          mammouth-pkg = mammouth.packages.${system}.default;
        };

        modules = [
          ./home.nix
        ];
      };

      # Default output: apply the configuration
      packages.${system}.default =
        self.homeConfigurations.taminaru.config.activationPackage;
    };
}
