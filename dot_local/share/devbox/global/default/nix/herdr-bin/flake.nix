{
  description = "Herdr release binary packaged for the global devbox";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "0.6.6";
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system (import nixpkgs { inherit system; }));
      assets = {
        aarch64-darwin = {
          name = "herdr-macos-aarch64";
          hash = "sha256-VDf4fKx02whbvFFhmAT7YQZvSfd8JX8zMzEDW75ebD8=";
        };
        x86_64-darwin = {
          name = "herdr-macos-x86_64";
          hash = "sha256-9QeO6Lr5jyt9iRhgZerKunm5E59mEvxVQJJ8gZq7Z8U=";
        };
        aarch64-linux = {
          name = "herdr-linux-aarch64";
          hash = "sha256-aYI3XQGRAW4myM4XNC6lJHiPbDrrTzlJ0AFfUeM9FtI=";
        };
        x86_64-linux = {
          name = "herdr-linux-x86_64";
          hash = "sha256-DQwKOUaUNO+zYw1yWfn5FGO61yekwQ7RxAwG0wvA6qw=";
        };
      };
    in {
      packages = forAllSystems (system: pkgs:
        let asset = assets.${system}; in {
          default = self.packages.${system}.herdr;
          herdr = pkgs.stdenvNoCC.mkDerivation {
            pname = "herdr";
            inherit version;
            src = pkgs.fetchurl {
              url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/${asset.name}";
              hash = asset.hash;
            };
            dontUnpack = true;
            installPhase = ''
              runHook preInstall
              install -Dm755 "$src" "$out/bin/herdr"
              runHook postInstall
            '';
            meta = {
              description = "Terminal-native agent runtime and multiplexer";
              homepage = "https://herdr.dev/";
              platforms = systems;
            };
          };
        });
    };
}
