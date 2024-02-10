{
  description = "Basic flake (edited by kurtl)";

  # inputs = {
  #   opam-nix.url = "github:tweag/opam-nix";
  #   flake-utils.url = "github:numtide/flake-utils";
  #   nixpkgs.follows = "opam-nix/nixpkgs";
  # };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Convenience functions for writing flakes
    flake-utils.url = "github:numtide/flake-utils";
    # Precisely filter files copied to the nix store
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, flake-utils, nixpkgs, nix-filter }:
    flake-utils.lib.eachDefaultSystem (system:
      let
	# pkgs = import nixpkgs { inherit system; };
	legacyPackages = nixpkgs.legacyPackages.${system};
	ocamlPackages = legacyPackages.ocamlPackages;
	# lib = legacyPackages.lib;

        # Filtered sources (prevents unecessary rebuilds)
        sources = {
          ocaml = nix-filter.lib {
            root = ./.;
            include = [
              ".ocamlformat"
              "dune-project"
              (nix-filter.lib.inDirectory "bin")
              (nix-filter.lib.inDirectory "lib")
              (nix-filter.lib.inDirectory "test")
            ];
          };

          nix = nix-filter.lib {
            root = ./.;
            include = [
              (nix-filter.lib.matchExt "nix")
            ];
          };
        };
      in
      {
	packages = {
	# The package that will be built or run by default. For example:
          #
          #     $ nix build
          #     $ nix run -- <args?>
          #
          default = self.packages.${system}.kurtl_web;

	  kurtl_web = ocamlPackages.buildDunePackage {
	    pname = "kurtl_web";
	    version = "0.1.0";
	    duneVersion = "3";
	    src = sources.ocaml;

	    buildInputs = [
	      # ocaml package dependencies needed to build go here.
	    ];

	    strictDeps = true;

	    preBuild = ''
	      dune build kurtl_web.opam
	    '';
	  };
	};

	devShells.default = legacyPackages.mkShell {
	  packages = [
	    legacyPackages.nixpkgs-fmt
	    legacyPackages.ocamlformat
	    legacyPackages.fswatch
	    legacyPackages.opam
	    legacyPackages.openssl
	    ocamlPackages.dune_3
	    ocamlPackages.ocaml
	    ocamlPackages.odoc
	  ];
	};
      });
}
