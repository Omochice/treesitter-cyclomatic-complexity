{
  description = ''
    A Neovim plugin that displays cyclomatic complexity values using nvim-treesitter.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:Omochice/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      flake-utils,
      nur,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nur.overlays.default ];
        };
        treefmt = treefmt-nix.lib.evalModule pkgs (
          { ... }:
          {
            programs = {
              # keep-sorted start block=yes
              formatjson5 = {
                enable = true;
                indent = 2;
              };
              keep-sorted.enable = true;
              nixfmt.enable = true;
              stylua = {
                enable = true;
                settings = {
                  indent_type = "Spaces";
                  indent_width = 2;
                  quote_style = "AutoPreferDouble";
                  call_parentheses = "Always";
                };
              };
              yamlfmt = {
                enable = true;
                settings = {
                  formatter = {
                    type = "basic";
                    retain_line_breaks_single = true;
                  };
                };
              };
              # keep-sorted end
            };
          }
        );
        runAs =
          name: runtimeInputs: text:
          let
            program = pkgs.writeShellApplication {
              inherit name runtimeInputs text;
            };
          in
          {
            type = "app";
            program = "${program}/bin/${name}";
          };
      in
      {
        formatter = treefmt.config.build.wrapper;
        checks = {
          formatting = treefmt.config.build.check self;
        };
        apps = {
          check-action =
            ''
              actionlint --version
              actionlint
              ghalint --version
              ghalint run
              zizmor --version
              zizmor .github/workflows .github/actions
            ''
            |> runAs "check-action" [
              pkgs.actionlint
              pkgs.ghalint
              pkgs.zizmor
            ];
        };
        devShells = {
          default = pkgs.mkShell {
            packages = [
              treefmt.config.build.wrapper
              pkgs.actionlint
              pkgs.ghalint
              pkgs.zizmor
            ];
          };
        };
      }
    );
}
