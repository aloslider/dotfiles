{
  description = "Nix packages";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "user-packages";
        paths = with pkgs; [
          nixfmt
        ];
      };
    };
}
