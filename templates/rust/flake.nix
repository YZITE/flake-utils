{
  description = "a rust program";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    yz-flake-utils.url = "github:YZITE/flake-utils";
    # needed for default.nix, shell.nix
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = { nixpkgs, yz-flake-utils, ... }:
    yz-flake-utils.lib.mkFlakeFromProg {
      prevpkgs = nixpkgs;
      progname = "myprog";
      drvBuilder = final: prev: (final.pkgs.callPackage ./Cargo.nix {}).rootCrate.build;
    };
}
