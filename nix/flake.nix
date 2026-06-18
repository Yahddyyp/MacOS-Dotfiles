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
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }: let
    secrets = if builtins.pathExists ./secrets.nix then import ./secrets.nix else { };
    username = let u = builtins.getEnv "USER"; in if u != "" then u else secrets.username or "changeme";
    system = "aarch64-darwin";
    specialArgs = { inherit username; };
  in {
    darwinConfigurations.${username} = nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ./home.nix;
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
  };
}
