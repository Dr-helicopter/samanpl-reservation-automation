{
  description = "samanpl reservation automation";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      pythonEnv = pkgs.python3.withPackages (p: with p; [
        playwright
      ]);

      pwDriver = pkgs.playwright-driver;

      runtimeEnv = {
        PLAYWRIGHT_BROWSERS_PATH = "${pwDriver.browsers}";
        PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
      };

    in
    {
      apps.${system}.default = {
        type = "app";
		  program = "${pkgs.writeShellScript "samanpl" ''
			cd ${self}
			export PLAYWRIGHT_BROWSERS_PATH="${pwDriver.browsers}"
			export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
			exec ${pythonEnv}/bin/python ${self}/reserve.py
		  ''}";
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pythonEnv
          pkgs.python314Packages.python-lsp-server
          pwDriver
          pwDriver.browsers
        ];

        inherit (runtimeEnv) PLAYWRIGHT_BROWSERS_PATH;
        PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";

        shellHook = ''
          python --version
        '';
      };
    };
}
