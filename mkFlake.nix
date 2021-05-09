{ eachSystem }:

{ prevpkgs
, overlay
, defaultProgName ? null
, contentAddressedByDefault ? true
, systems ? prevpkgs.lib.platforms.all
}:

let
  dummyov = overlay {} {};

  ret = system:
    let
      allpkgs = import prevpkgs {
        inherit system;
        config = {
          inherit contentAddressedByDefault;
        };
        overlays = [ overlay ];
      };
      packages = allpkgs.lib.attrsets.filterAttrs (n: v: dummyov ? ${n}) allpkgs;
      retpre = {
        packages = packages;
        apps = builtins.mapAttrs
          (n: drv: {
          type = "app";
          program = drv.outPath
            + (drv.passthru.exePath or ("/bin/" + (drv.pname or drv.name)));
        }) packages;
      };
    in retpre // (if defaultProgName == null then { }
      else {
        defaultPackage = retpre.packages.${defaultProgName};
        defaultApp = retpre.apps.${defaultProgName};
        devShell = allpkgs.mkShell {
          buildInputs = allpkgs.${defaultProgName}.buildInputs;
        };
      })
;

in { inherit overlay; } // (eachSystem systems ret)
