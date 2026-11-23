{
  description = "Yahddyyp's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pass-tomb-osx = {
      url = "github:Yahddyyp/pass-tomb-osx";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };

    catppuccin.url = "github:catppuccin/nix";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { nixpkgs, nix-darwin, home-manager, mac-app-util, pass-tomb-osx, catppuccin, nix-homebrew, ... }: let
    usernameFromEnv = let
      su = builtins.getEnv "SUDO_USER";
      u  = builtins.getEnv "USER";
    in if su != "" then su else if u != "" then u else "nobody";
    username = usernameFromEnv;
    system = "aarch64-darwin";
    specialArgs = { inherit username pass-tomb-osx; };
  in {
    packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.nix;
    darwinConfigurations.${username} = nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        # Custom yabai version cause the nixpkgs version did not update
        {
          nixpkgs.overlays = [
            (import ./packages/yabai.nix)
          ];
        }
        ./darwin
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            sharedModules = [ 
              mac-app-util.homeManagerModules.default
              catppuccin.homeModules.catppuccin
            ];
            users.${username} = import ./home;
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
  };
}
