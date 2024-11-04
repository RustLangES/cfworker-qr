{
  system,
  pkgs,
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  crane,
  fenix,
  ...
}: let
  # fenix: rustup replacement for reproducible builds
  toolchain = fenix.${system}.fromToolchainFile {
    file = ./rust-toolchain.toml;
    sha256 = "sha256-yMuSb5eQPO/bHv+Bcf/US8LVMbf/G/0MSfiPwBhiPpk=";
  };
  # crane: cargo and artifacts manager
  craneLib = crane.overrideToolchain toolchain;

  nativeBuildInputs = with pkgs; [
    worker-build
    wasm-pack
    wasm-bindgen-cli
    binaryen
  ];

  buildInputs = with pkgs; [
    openssl
    pkg-config
    autoPatchelfHook
  ];

  worker = craneLib.buildPackage {
    doCheck = false;
    src = craneLib.cleanCargoSource (craneLib.path ./.);
    buildPhaseCargoCommand = "HOME=$(mktemp -d fake-homeXXXX) worker-build --release --mode no-install";

    installPhaseCommand = ''
      cp -r ./build $out
    '';

    nativeBuildInputs = with pkgs; nativeBuildInputs ++ [
      esbuild
    ];

    inherit buildInputs;
  };
in
{
  # `nix build`
  packages.default = worker;

  # `nix develop`
  devShells.default = craneLib.devShell {
    buildInputs = nativeBuildInputs ++ buildInputs;
  };
}
