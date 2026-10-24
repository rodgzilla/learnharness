{
  description = "LearnHarness desktop app, packaged from the published Linux AppImage";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # Version + AppImage hash of the latest published release. The hash is
      # the AppImage's sha512 from that release's latest-linux.yml.
      release = builtins.fromJSON (builtins.readFile ./nix/release.json);

      pname = "learnharness";
      inherit (release) version;
      src = pkgs.fetchurl {
        url = "https://github.com/amosblomqvist/learnharness/releases/download/v${version}/LearnHarness-${version}-x86_64.AppImage";
        inherit (release) hash;
      };
      contents = pkgs.appimageTools.extract { inherit pname version src; };

      learnharness = pkgs.appimageTools.wrapType2 {
        inherit pname version src;
        extraInstallCommands = ''
          install -Dm444 ${contents}/learnharness.desktop -t $out/share/applications
          substituteInPlace $out/share/applications/learnharness.desktop \
            --replace-fail 'Exec=AppRun' 'Exec=learnharness'
          cp -r ${contents}/usr/share/icons $out/share
        '';
        meta = {
          description = "An agent harness for learning: adaptive teaching, practice, and a persistent knowledge graph";
          homepage = "https://github.com/amosblomqvist/learnharness";
          license = pkgs.lib.licenses.agpl3Only;
          platforms = [ system ];
          sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
          mainProgram = "learnharness";
        };
      };
    in
    {
      packages.${system} = {
        inherit learnharness;
        default = learnharness;
      };
    };
}
