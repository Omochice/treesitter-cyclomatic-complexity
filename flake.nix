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
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mini-test = {
      url = "github:echasnovski/mini.test";
      flake = false;
    };
    luacov = {
      url = "github:keplerproject/luacov";
      flake = false;
    };
    luacov-reporter-lcov = {
      url = "github:daurnimator/luacov-reporter-lcov";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      flake-utils,
      nur-packages,
      git-hooks,
      mini-test,
      luacov,
      luacov-reporter-lcov,
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
        pre-commit-check = git-hooks.lib.${system}.run {
          package = pkgs.prek;
          src = ./.;
          hooks = {
            actionlint = {
              enable = true;
              stages = [ "pre-push" ];
            };
            ghalint = {
              enable = true;
              name = "ghalint";
              entry = "${pkgs.lib.getExe pkgs.ghalint} run";
              files = "^\\.github/workflows/";
              pass_filenames = false;
              stages = [ "pre-push" ];
            };
            # Claude Code sets CLAUDECODE; humans are covered by the pre-push hook
            gitleaks-commit = {
              enable = true;
              name = "gitleaks (claude commit)";
              entry = pkgs.lib.getExe (
                pkgs.writeShellApplication {
                  name = "gitleaks-when-claude";
                  runtimeInputs = [ pkgs.gitleaks ];
                  text = ''
                    if [ -z "''${CLAUDECODE:-}" ]; then
                      exit 0
                    fi
                    gitleaks git --pre-commit --staged --no-banner --redact
                  '';
                }
              );
              pass_filenames = false;
              stages = [ "pre-commit" ];
            };
            gitleaks-push = {
              enable = true;
              name = "gitleaks";
              entry = "${pkgs.lib.getExe pkgs.gitleaks} git --no-banner --redact";
              pass_filenames = false;
              stages = [ "pre-push" ];
            };
            renovate = {
              enable = true;
              name = "renovate-config-validator";
              entry = "${pkgs.lib.getExe' pkgs.renovate "renovate-config-validator"} --strict";
              files = "^renovate\\.json5$";
              stages = [ "pre-push" ];
            };
            treefmt = {
              enable = true;
              packageOverrides.treefmt = treefmt.config.build.wrapper;
              stages = [ "pre-push" ];
            };
            # The default only covers workflows, but composite actions are checked too
            zizmor = {
              enable = true;
              files = "^\\.github/(workflows|actions)/";
              stages = [ "pre-push" ];
            };
          };
        };
        devPackages = rec {
          # keep-sorted start block=yes
          actions = with pkgs; [
            actionlint
            ghalint
            zizmor
          ];
          # keep-sorted end
          default = [
            treefmt.config.build.wrapper
          ]
          ++ actions;
        };
        neovim = pkgs.neovim-unwrapped;
        # nvim-treesitter's main branch installs grammars at runtime instead of
        # shipping them, so `withAllGrammars` now yields a derivation with no
        # parser in it. Tests then ran against the grammars Neovim bundles, which
        # cover only c and lua, and every query for the other supported languages
        # went unexercised. Linking the grammars directly keeps the parsers under
        # the version control of the nixpkgs pin.
        treesitter = pkgs.linkFarm "treesitter-parsers" (
          map (lang: {
            name = "parser/${lang}.so";
            path = "${pkgs.tree-sitter-grammars."tree-sitter-${lang}"}/parser";
          }) supportedLanguages
        );
        # Kept in step with the `queries` table in lua/*/parser.lua.
        supportedLanguages = [
          # keep-sorted start
          "c"
          "cpp"
          "go"
          "java"
          "javascript"
          "lua"
          "python"
          "rust"
          "typescript"
          # keep-sorted end
        ];
        mini = mini-test;
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
            luacovPath = "${luacov}/src";
            datafilePath = "${pkgs.lua51Packages.datafile}/share/lua/5.1";
            lcovReporterPath = "${luacov-reporter-lcov}";
          in
          mkInitVim ''
            lua package.path = '${luacovPath}/?.lua;${luacovPath}/?/init.lua;${datafilePath}/?.lua;${datafilePath}/?/init.lua;${lcovReporterPath}/?.lua;${lcovReporterPath}/?/init.lua;' .. package.path
            lua require("luacov")
          '';
        testScript = pkgs.writeShellScriptBin "test" ''
          cd "$(${pkgs.lib.getExe pkgs.git} rev-parse --show-toplevel)"
          ${pkgs.lib.getExe neovim} --headless --clean -u ${initVim}/init.vim -l test/run.lua
        '';
        coverageScript = pkgs.writeShellScriptBin "coverage" ''
          cd "$(${pkgs.lib.getExe pkgs.git} rev-parse --show-toplevel)"
          ${pkgs.lib.getExe neovim} --headless --clean -u ${initVimWithCoverage}/init.vim -l test/run.lua
          export LUA_PATH="${luacov}/src/?.lua;${luacov}/src/?/init.lua;${pkgs.lua51Packages.datafile}/share/lua/5.1/?.lua;${pkgs.lua51Packages.datafile}/share/lua/5.1/?/init.lua;${luacov-reporter-lcov}/?.lua;${luacov-reporter-lcov}/?/init.lua;;"
          ${pkgs.lib.getExe pkgs.lua5_1} ${luacov}/src/bin/luacov -r lcov
          ${pkgs.lib.getExe pkgs.gnused} -i "s|SF:$PWD/|SF:|g" luacov.report.out
        '';
      in
      {
        # keep-sorted start block=yes
        apps = {
          # keep-sorted start block=yes
          coverage = {
            type = "app";
            program = pkgs.lib.getExe coverageScript;
          };
          test = {
            type = "app";
            program = pkgs.lib.getExe testScript;
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
          pre-commit = pre-commit-check;
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
          (pkgs.lib.attrsets.mapAttrs (
            name: buildInputs:
            pkgs.mkShell {
              buildInputs = buildInputs ++ pre-commit-check.enabledPackages;
              inherit (pre-commit-check) shellHook;
            }
          ))
        ];
        formatter = treefmt.config.build.wrapper;
        # keep-sorted end
      }
    );
}
