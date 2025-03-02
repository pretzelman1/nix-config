{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "catppuccin-ghostty";
  version = "unstable-2024-01-14";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "ghostty";
    rev = "9e38fc2b4e76d4ed5ff9edc5ac9e4081c7ce6ba6";
    sha256 = "sha256-RlgTeBkjEvZpkZbhIss3KxQcvt0goy4WU+w9d2XCOnw=";
  };

  installPhase = ''
    mkdir -p $out/share/ghostty-catppuccin
    cp -r themes/* $out/share/ghostty-catppuccin/
  '';

  meta = with lib; {
    description = "Soothing pastel theme for Ghostty";
    homepage = "https://github.com/catppuccin/ghostty";
    license = licenses.mit;
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    maintainers = [addg0];
  };
}
