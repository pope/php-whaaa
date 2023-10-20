{
  description = "PHP Whaaaa?";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-formatter-pack = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-formatter-pack, rust-overlay, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-linux"
      ];
    in
    {
      devShells = eachSystem (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
        with pkgs;
        {
          default = mkShell {
            nativeBuildInputs = [
              gnumake
              go_1_21
              gopls
              (php.buildEnv {
                extensions = { enabled, all }: enabled ++ (with all; [
                  # xdebug
                  openswoole
                ]);
                # extraConfig = ''
                #   xdebug.mode=debug
                # '';
              })
              # phpPackages.composer
              (php.withExtensions ({ all, enabled }:
                enabled ++ (with all; [ openswoole ]))
              ).packages.composer
              phpactor
              (buildGoModule {
                name = "plow";
                src = fetchFromGitHub {
                  owner = "six-ddc";
                  repo = "plow";
                  rev = "343b7510ccfa477d9c0f3d9aeeaa0834e118c44a";
                  sha256 = "sha256-TynFq7e4MtZlA5SmGMybhmCVw67yHYgZWffQjuyhTDA=";
                };
                vendorSha256 = "sha256-t2lBPyCn8bu9hLsWmaCGir9egbX0mQR+8kB0RfY7nHE=";
              })
              rust-bin.stable.latest.default
              rust-analyzer
              rustfmt
            ];
          };
        }
      );
      formatter = eachSystem (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );
    };
  # {
  #   packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
  #   packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
  # };
}
