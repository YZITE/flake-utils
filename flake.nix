{
  description = "yet another Nix flake-utils library";
  outputs = { self }: {
    lib = rec {
      mkFlake = import ./mkFlake.nix;
      mkFlakeFromProg =
        { prevpkgs, progname, drvBuilder
        , systems ? prevpkgs.lib.platforms.all
        }: mkFlake rec {
          inherit prevpkgs systems;
          overlay = final: prev: { ${progname} = drvBuilder final prev; };
          defaultProgName = progname;
        };
    };

    templates = {
      rust = {
        path = ./templates/rust;
        description = "A custom rust binary crate package";
      };
    };
  };
}
