{
  description = "yet another Nix flake-utils library";
  outputs = { self }: {
    lib = import ./lib.nix;

    templates = {
      rust = {
        path = ./templates/rust;
        description = "A custom rust binary crate package";
      };
    };
  };
}
