{
  description = "Nix Moment";

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

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    pass-tomb-osx.url = "github:Yahddyyp/pass-tomb-osx";
  };

  outputs = { nixpkgs, nix-darwin, home-manager, nix-homebrew, pass-tomb-osx, ... }: let
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
        nix-homebrew.darwinModules.nix-homebrew
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.${username} = import ./home.nix;
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
  };
}
