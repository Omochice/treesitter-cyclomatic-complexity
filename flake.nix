{
  description = "nvim plugin shows cyclomatic complexity by tree-sitter";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-packages = {
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
      nur-packages,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            nur-packages.overlays.default
          ];
        };
        treefmt = treefmt-nix.lib.evalModule pkgs (
          { ... }:
          let
            rumdlConfig = (pkgs.formats.toml { }).generate "rumdl.toml" {
              # keep-sorted start
              MD004.style = "dash";
              MD007.indent = 4;
              MD007.style = "fixed";
              MD041.enabled = false;
              MD049.style = "underscore";
              MD050.style = "asterisk";
              MD055.style = "leading-and-trailing";
              MD060.enabled = true;
              MD060.style = "aligned";
              global.length = 0;
              # keep-sorted end
            };
          in
          {
            settings.global.excludes = [ ];
            settings.formatter = {
              # keep-sorted start block=yes
              rumdl = {
                command = "${pkgs.lib.getExe pkgs.rumdl}";
                options = [
                  "fmt"
                  "--config"
                  (toString rumdlConfig)
                ];
                includes = [ "*.md" ];
              };
              # keep-sorted end
            };
            programs = {
              # keep-sorted start block=yes
              keep-sorted.enable = true;
              nixfmt.enable = true;
              stylua.enable = true;
              toml-sort.enable = true;
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
        devPackages = rec {
          # keep-sorted start block=yes
          actions = with pkgs; [
            actionlint
            ghalint
            zizmor
          ];
          nvfetcher = [
            pkgs.nvfetcher
          ];
          # keep-sorted end
          default = [
            treefmt.config.build.wrapper
          ]
          ++ actions
          ++ nvfetcher;
        };
        sources = pkgs.callPackage ./_sources/generated.nix { };
        neovim = pkgs.neovim-unwrapped;
        treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        mini = pkgs.vimPlugins.mini-nvim;
        luacov = pkgs.lua51Packages.luacov;
        luacov-reporter-lcov = sources.luacov-reporter-lcov.src;
        mkInitVim =
          extraConfig:
          pkgs.writeTextFile {
            name = "init-vim";
            destination = "/init.vim";
            text = ''
              set runtimepath+=.
              set runtimepath+=${treesitter}
              set runtimepath+=${mini}
              ${extraConfig}
            '';
          };
        initVim = mkInitVim "";
        initVimWithCoverage =
          let
            luacovPath = "${luacov}/share/lua/5.1";
            datafilePath = "${pkgs.lua51Packages.datafile}/share/lua/5.1";
            lcovReporterPath = "${luacov-reporter-lcov}";
          in
          mkInitVim ''
            lua package.path = '${luacovPath}/?.lua;${luacovPath}/?/init.lua;${datafilePath}/?.lua;${datafilePath}/?/init.lua;${lcovReporterPath}/?.lua;${lcovReporterPath}/?/init.lua;' .. package.path
            lua require("luacov")
          '';
        testScript = pkgs.writeShellScriptBin "test" ''
          cd "$(${pkgs.lib.getExe pkgs.git} rev-parse --show-toplevel)"
          ${neovim}/bin/nvim --headless --clean -u ${initVim}/init.vim -l test/run.lua
        '';
        coverageScript = pkgs.writeShellScriptBin "coverage" ''
          cd "$(${pkgs.lib.getExe pkgs.git} rev-parse --show-toplevel)"
          ${neovim}/bin/nvim --headless --clean -u ${initVimWithCoverage}/init.vim -l test/run.lua
          export LUA_PATH="${luacov-reporter-lcov}/?.lua;${luacov-reporter-lcov}/?/init.lua;;"
          ${luacov}/bin/luacov -r lcov
          ${pkgs.gnused}/bin/sed -i "s|SF:$PWD/|SF:|g" luacov.report.out
        '';
      in
      {
        # keep-sorted start block=yes
        apps = {
          # keep-sorted start block=yes
          coverage = {
            type = "app";
            program = "${coverageScript}/bin/coverage";
          };
          test = {
            type = "app";
            program = "${testScript}/bin/test";
          };
          # keep-sorted end
        };
        checks = {
          # keep-sorted start
          actions =
            pkgs.runCommand "check-actions"
              {
                buildInputs = with pkgs; [
                  actionlint
                  ghalint
                  zizmor
                ];
                src = self;
              }
              ''
                cd $src
                actionlint .github/**/*.{yaml,yml}
                ghalint run
                zizmor .github/workflows .github/actions
                touch $out
              '';
          formatting = treefmt.config.build.check self;
          renovate =
            pkgs.runCommand "validate-renovate-config"
              {
                buildInputs = with pkgs; [
                  renovate
                ];
                src = self;
              }
              ''
                cd $src
                renovate-config-validator --strict renovate.json5
                touch $out
              '';
          # keep-sorted end
        };
        devShells = pkgs.lib.pipe devPackages [
          (pkgs.lib.attrsets.mapAttrs (name: buildInputs: pkgs.mkShell { inherit buildInputs; }))
        ];
        formatter = treefmt.config.build.wrapper;
        # keep-sorted end
      }
    );
}
