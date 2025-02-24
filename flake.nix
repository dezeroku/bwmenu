{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (poetry2nix.legacyPackages.${system}) mkPoetryApplication defaultPoetryOverrides;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          bwmenu = mkPoetryApplication {
            projectDir = self;
            buildInputs = with pkgs; [ bitwarden-cli gnupg libnotify rofi xdotool ];
          };
          default = self.packages.${system}.bwmenu;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            poetry2nix.packages.${system}.poetry
            self.packages.${system}.bwmenu.dependencyEnv
          ];
        };
      });
}
