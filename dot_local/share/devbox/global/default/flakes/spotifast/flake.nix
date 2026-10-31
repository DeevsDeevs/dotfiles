{
  description = "Official Spotifast macOS release";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

  outputs = { nixpkgs, ... }: {
    packages = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        spotifast-app = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "spotifast";
          version = "0.15.0";
          src = pkgs.fetchurl {
            url = "https://github.com/crmne/spotifast/releases/download/v${version}/spotifast-v${version}-macos-universal.dmg";
            sha256 = "7ee148690c4db87004bc1db3874021494d125a85a0c9be8a1f1efac6cefe8de1";
          };
          nativeBuildInputs = [ pkgs._7zz ];
          unpackPhase = ''
            7zz x "$src" -o.
          '';
          dontConfigure = true;
          dontBuild = true;
          # Preserve the release's code signature.
          dontFixup = true;
          installPhase = ''
            runHook preInstall
            mkdir -p "$out/Applications" "$out/bin"
            cp -R Spotifast.app "$out/Applications/"
            ln -s "$out/Applications/Spotifast.app/Contents/MacOS/Spotifast" "$out/bin/spotifast"
            runHook postInstall
          '';
          meta = {
            description = "Fast native Spotify client";
            homepage = "https://spotifast.rocks";
            license = pkgs.lib.licenses.mit;
            mainProgram = "spotifast";
            platforms = [ "aarch64-darwin" "x86_64-darwin" ];
          };
        };
      });
  };
}
