{
  description = "Yahddyyp's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-mac-app-identity = {
      url = "github:natsukium/nix-mac-app-identity";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pass-tomb-osx = {
      url = "github:Yahddyyp/pass-tomb-osx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    let
      system = "aarch64-darwin";

      username =
        let
          sudoUser = builtins.getEnv "SUDO_USER";
          user = builtins.getEnv "USER";
        in
        if sudoUser != "" then
          sudoUser
        else if user != "" then
          user
        else
          "nobody";

      specialArgs = {
        inherit inputs username;
      };
    in
    {
      packages.${system}.default = nixpkgs.legacyPackages.${system}.nix;

      darwinConfigurations.${username} = nix-darwin.lib.darwinSystem {
        inherit system specialArgs;

        modules = [
          ./darwin

          inputs.nix-homebrew.darwinModules.nix-homebrew
          inputs.nix-mac-app-identity.darwinModules.default
          inputs.spicetify-nix.darwinModules.default

          # Use a custom fork of yabai as upstream is broken
          {
            nixpkgs.overlays = [
              (import ./overlays/yabai.nix)
            ];
          }

          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = specialArgs;
              sharedModules = [
                inputs.catppuccin.homeModules.catppuccin
              ];
              users.${username} = import ./home;
            };
          }
        ];
      };
    };
}
