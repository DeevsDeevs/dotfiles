{
  description = "Official Pi release, pinned until llm-agents.nix catches up";

  inputs.llm-agents.url = "github:numtide/llm-agents.nix";
  inputs.nixpkgs.follows = "llm-agents/nixpkgs";

  outputs = { nixpkgs, llm-agents, ... }:
    let
      version = "1.1.0";
      releases = {
        x86_64-linux = {
          platform = "linux-x64";
          sha256 = "3faa94666cd3849d37af320ff749407d0271b07a9b94f420c87e30866e10e289";
        };
        aarch64-linux = {
          platform = "linux-arm64";
          sha256 = "f3b0cac459f9df5420e4e48b48e95d81bfab57b701dd3fe4b08fda7d11d27dab";
        };
        aarch64-darwin = {
          platform = "darwin-arm64";
          sha256 = "3455b13de35c15a5893cdebc922678199e90a7ce99b06cbc23f37860e90d63c7";
        };
        x86_64-darwin = {
          platform = "darwin-x64";
          sha256 = "8fdd9149ae27e7470a6a10ed8a7c0ed80738d55adec80a8d7764f6386d1e658b";
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
