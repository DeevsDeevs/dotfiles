{
  description = "Official Pi release, pinned until llm-agents.nix catches up";

  inputs.llm-agents.url = "github:numtide/llm-agents.nix";
  inputs.nixpkgs.follows = "llm-agents/nixpkgs";

  outputs = { nixpkgs, llm-agents, ... }:
    let
      version = "1.4.0";
      releases = {
        x86_64-linux = {
          platform = "linux-x64";
          sha256 = "f2e4e4329603223d03260cdb8bd5033dbdc1f73ba58ab8939db2e56546e115d2";
        };
        aarch64-linux = {
          platform = "linux-arm64";
          sha256 = "fa5829c7ef83ffeaebba015715c8306220f89b2aa8a00154efbba98dd5440156";
        };
        aarch64-darwin = {
          platform = "darwin-arm64";
          sha256 = "79d9979d76a2a5adb7c28e27e9b44629928ccd0dc9fbb6ae7217860bd5e8be5d";
        };
        x86_64-darwin = {
          platform = "darwin-x64";
          sha256 = "1bdefc9e1074c1de458ea9f2e43e6013ce49cd05326009b3de144037036585e2";
        };
      };
    in {
      packages = nixpkgs.lib.genAttrs (builtins.attrNames releases) (system:
        let
          pkgs = import nixpkgs { inherit system; };
          inherit (pkgs) lib stdenv;
          release = releases.${system};
        in {
          pi = pkgs.stdenvNoCC.mkDerivation {
            pname = "pi";
            inherit version;
            src = pkgs.fetchurl {
              url = "https://github.com/earendil-works/pi/releases/download/v${version}/pi-${release.platform}.tar.gz";
              inherit (release) sha256;
            };
            nativeBuildInputs = [ pkgs.makeWrapper ]
              ++ lib.optional stdenv.hostPlatform.isLinux llm-agents.packages.${system}.formatelf;
            buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ pkgs.libxcb pkgs.openssl pkgs.stdenv.cc.cc.lib ];
            dontConfigure = true;
            dontBuild = true;
            # Bun embeds application data in the executable; stripping can destroy it.
            dontStrip = true;
            dontPatchShebangs = true;
            installPhase = ''
              runHook preInstall
              mkdir -p "$out/libexec/pi" "$out/bin"
              cp -r . "$out/libexec/pi/"
              makeWrapper "$out/libexec/pi/pi" "$out/bin/pi" \
                --prefix PATH : ${lib.makeBinPath [ pkgs.fd pkgs.ripgrep ]} \
                --set PI_PACKAGE_DIR "$out/libexec/pi" \
                --set PI_SKIP_VERSION_CHECK 1 \
                --set PI_TELEMETRY 0
              runHook postInstall
            '';
            meta = {
              description = "Terminal coding agent";
              homepage = "https://pi.dev";
              license = lib.licenses.mit;
              mainProgram = "pi";
              platforms = builtins.attrNames releases;
            };
          };
        });
    };
}
