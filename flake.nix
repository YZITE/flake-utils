{
  description = "yet another Nix flake-utils library";
  outputs = { self }: {
    lib = rec {
      # inlined from github:numtide/flake-utils
      eachSystem = systems: f:
        let
          op = attrs: system:
            let
              ret = f system;
              op = attrs: key:
                attrs //
                {
                  ${key} = (attrs.${key} or { }) // { ${system} = ret.${key}; };
                }
              ;
            in
            builtins.foldl' op attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } systems;

      mkFlake = import ./mkFlake.nix { inherit eachSystem; };
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
