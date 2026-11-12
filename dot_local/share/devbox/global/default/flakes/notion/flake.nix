{
  description = "Official Notion macOS release";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/36173dbc6ff2b383c4d03b002fd1ea58e2e4dbcd";

  outputs = { nixpkgs, ... }: {
    packages = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        isArm = system == "aarch64-darwin";
      in {
        notion-app = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "notion-app";
          version = "7.43.0";
          src = pkgs.fetchurl {
            url = "https://desktop-release.notion-static.com/Notion-${if isArm then "arm64-" else ""}${version}.zip";
            hash = if isArm
              then "sha512-NaVvnESe+tNMotaBM2bFiWCASSUEleXC6IDLa6eQ6OW+aCrU5KXwEq7UXyPIw0dKbxwbAz4+Rn6Lbp9H9hPlXQ=="
              else "sha512-tvwkByyaoHis+jBLVHRzYH22esvOf206ZA2+ntWGoY/gx7kEo7PJPR7/9DeNNaBfaXlD6PKJ+W975vyi5C1Gog==";
          };
          nativeBuildInputs = [ pkgs.unzip ];
          sourceRoot = ".";
          dontConfigure = true;
          dontBuild = true;
          # Preserve the official app's code signature.
          dontFixup = true;
          installPhase = ''
            runHook preInstall
            mkdir -p "$out/Applications"
            cp -R Notion.app "$out/Applications/"
            runHook postInstall
          '';
          meta = {
            description = "Write, plan, collaborate, and get organized";
            homepage = "https://www.notion.com/";
            license = pkgs.lib.licenses.unfree;
            platforms = [ "aarch64-darwin" "x86_64-darwin" ];
          };
        };
      });
  };
}
