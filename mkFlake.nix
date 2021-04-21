{ eachSystem }:

{ prevpkgs
, overlay
, defaultProgName ? null
, systems ? prevpkgs.lib.platforms.all
}:

let
  dummyov = overlay {} {};

  ret = system:
    let
      allpkgs = import prevpkgs {
        inherit system;
        overlays = [ overlay ];
      };
      packages = allpkgs.lib.attrsets.filterAttrs (n: v: dummyov ? ${n}) allpkgs;
    in
    {
      packages = packages;
      apps = builtins.mapAttrs
        (n: drv: {
        type = "app";
        program = drv.outPath
          + (drv.passthru.exePath or ("/bin/" + (drv.pname or drv.name)));
      }) packages;
    };

  retall = eachSystem systems ret;
  mapToDPN = builtins.mapAttrs (name: value: value.${defaultProgName});

in { inherit overlay; } // retall // (
  if defaultProgName == null then { }
  else {
    defaultPackage = mapToDPN retall.packages;
    defaultApp = mapToDPN retall.apps;
  }
)
