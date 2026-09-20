{
  lib,
  stdenv,
  requireFile,
  autoPatchelfHook,
  makeWrapper,
  wayland,
  vulkan-loader,
  libGL,
  libx11,
}:
stdenv.mkDerivation {
  pname = "delta-gui";
  version = "0.16.1";

  src = requireFile {
    name = "delta-linux-x86_64.tar.gz";
    hash = "sha256-+G91zPV+3UYF7OxVEhJcQgd6HHA67c7/WQNxSp6oB4Y=";
    message = ''
      Download Delta 0.16.1 for Linux x86_64 from https://delta.dev/download,
      place it in NixOS/home/keishis/delta/.local/, then run from the repository root:
        nix-store --add-fixed sha256 NixOS/home/keishis/delta/.local/delta-linux-x86_64.tar.gz
      The archive must match the hash in delta/package.nix.
    '';
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  # These libraries are loaded with dlopen, so ELF NEEDED entries omit them.
  runtimeDependencies = [
    (lib.getLib wayland)
    (lib.getLib vulkan-loader)
    (lib.getLib libGL)
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r bin lib share "$out/"
    substituteInPlace "$out/share/applications/dev.zed.Delta.desktop" \
      --replace-fail 'Exec=delta cli open %U' "Exec=$out/bin/delta cli open %U"
    runHook postInstall
  '';

  # The bundled libxkbcommon otherwise looks for Compose tables under /usr/share.
  postFixup = ''
    wrapProgram "$out/bin/delta" \
      --set-default XLOCALEDIR "${libx11}/share/X11/locale"
  '';

  meta = {
    description = "Delta GUI for coding with agents";
    homepage = "https://delta.dev/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "delta";
  };
}
