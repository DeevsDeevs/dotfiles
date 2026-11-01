{
  description = "Official Hex macOS release";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

  outputs = { nixpkgs, ... }: {
    packages.aarch64-darwin =
      let
        pkgs = import nixpkgs { system = "aarch64-darwin"; };
      in {
        hex = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "hex";
          version = "3.0.0";
          src = pkgs.fetchurl {
            url = "https://github.com/anomalyco/hex/releases/download/v${version}/Hex-${version}-macos-arm64.zip";
            sha256 = "90914fb168aee382e42f142994ae4a037b7851807cdf97430f16a413a1daa2d8";
          };
          nativeBuildInputs = [ pkgs.unzip ];
          sourceRoot = ".";
          dontConfigure = true;
          dontBuild = true;
          # Preserve the release's code signature and bundled model runtime.
          dontFixup = true;
          installPhase = ''
            runHook preInstall
            mkdir -p "$out/Applications" "$out/bin"
            cp -R Hex.app "$out/Applications/"
            ln -s "$out/Applications/Hex.app/Contents/MacOS/hex" "$out/bin/hex"
            runHook postInstall
          '';
          meta = {
            description = "Local-first voice dictation";
            homepage = "https://anoma.ly/hex/";
            license = pkgs.lib.licenses.mit;
            mainProgram = "hex";
            platforms = [ "aarch64-darwin" ];
          };
        };
      };
  };
}
