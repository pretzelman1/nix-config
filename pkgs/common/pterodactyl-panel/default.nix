{
  lib,
  stdenv,
  fetchurl,
  php,
  composer,
}:
stdenv.mkDerivation rec {
  pname = "pterodactyl-panel";
  version = "1.11.10";

  src = fetchurl {
    url = "https://github.com/pterodactyl/panel/releases/download/v${version}/panel.tar.gz";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with real hash
  };

  nativeBuildInputs = [php composer];

  installPhase = ''

  '';

  meta = with lib; {
    description = "Pterodactyl Panel (Laravel Web UI)";
    homepage = "https://github.com/pterodactyl/panel";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
