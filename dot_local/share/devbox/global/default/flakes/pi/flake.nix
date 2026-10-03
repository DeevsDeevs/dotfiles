{
  description = "Official Pi release, pinned until llm-agents.nix catches up";

  inputs.llm-agents.url = "github:numtide/llm-agents.nix";
  inputs.nixpkgs.follows = "llm-agents/nixpkgs";

  outputs = { nixpkgs, llm-agents, ... }:
    let
      version = "1.0.1";
      releases = {
        x86_64-linux = {
          platform = "linux-x64";
          sha256 = "1940ecabcbd54ddd1a78dd2d587c189c5ced83e775a817855a9f5d1dd799c5f2";
        };
        aarch64-linux = {
          platform = "linux-arm64";
          sha256 = "3e00467be37695eb2e34c06a95440e21631159f3367f7fe396237fb6f9f4bd0a";
        };
        aarch64-darwin = {
          platform = "darwin-arm64";
          sha256 = "de35e0025b136eb37693054ca658c010b6327a12aaff438ae87c4d1c94f99e6c";
        };
        x86_64-darwin = {
          platform = "darwin-x64";
          sha256 = "f4d2e9195454dfc922841224844953dc60f38aaffdff1ba9cde3565d9aa2835b";
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
