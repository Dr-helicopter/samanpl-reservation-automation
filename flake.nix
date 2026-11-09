{
  description = "Python development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default =
        let
          pwDriver = pkgs.playwright-driver;
        in
        pkgs.mkShell {
          packages = with pkgs; [
            python3
			python314Packages.python-lsp-server
            (python3.withPackages (p: with p; [ playwright ]))
            playwright.browsers
          ];
          PLAYWRIGHT_BROWSERS_PATH = "${pwDriver.browsers}";
          PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";

          shellHook = ''
            echo "Python development environment"
            python --version
          '';
        };
    };
}
