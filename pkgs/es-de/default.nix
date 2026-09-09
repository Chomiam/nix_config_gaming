{ appimageTools
, fetchurl
, lib
, vulkan-loader
, libGL
, wayland
, libxkbcommon
, pipewire
, pulseaudio
}:

let
  metadata = builtins.fromJSON (builtins.readFile ./version.json);
  pname = "es-de";
  version = metadata.version;

  src = fetchurl {
    url = metadata.url;
    hash = metadata.hash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    vulkan-loader
    libGL
    wayland
    libxkbcommon
    pipewire
    pulseaudio
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/org.es_de.frontend.desktop $out/share/applications/org.es_de.frontend.desktop
    install -m 444 -D ${appimageContents}/org.es_de.frontend.svg $out/share/icons/hicolor/scalable/apps/org.es_de.frontend.svg
  '';

  meta = with lib; {
    description = "EmulationStation Desktop Edition (ES-DE) gaming frontend";
    homepage = "https://es-de.org";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "es-de";
  };
}
