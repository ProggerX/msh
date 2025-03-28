{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, astal, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = astal.lib.mkLuaPackage {
      inherit pkgs;
      name = "msh";
      src = ./src;

      extraPackages = [
        astal.packages.${system}.hyprland
        astal.packages.${system}.tray
        astal.packages.${system}.wireplumber
        pkgs.dart-sass
      ];
    };
  };
}
