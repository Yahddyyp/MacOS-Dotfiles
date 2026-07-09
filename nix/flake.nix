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
    usernameFromEnv = let
      su = builtins.getEnv "SUDO_USER";
      u  = builtins.getEnv "USER";
    in if su != "" then su else if u != "" then u else "";
    secrets = if builtins.pathExists ./secrets.nix then import ./secrets.nix else { };
    username = if usernameFromEnv != "" then usernameFromEnv else secrets.username or "changeme";
    system = "aarch64-darwin";
    specialArgs = { inherit username; };
  in {
    packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.nix;
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
