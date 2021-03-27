{ prevpkgs
, overlay
, defaultProgName ? null
, systems ? prevpkgs.lib.platforms.all
}:

let
  # inlined from github:numtide/flake-utils
  eachSystem = f:
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

  retall = eachSystem ret;
  mapToDPN = builtins.mapAttrs (name: value: value.${defaultProgName});

in { inherit overlay; } // retall // (
  if defaultProgName == null then { }
  else {
    defaultPackage = mapToDPN retall.packages;
    defaultApp = mapToDPN retall.apps;
  }
)
