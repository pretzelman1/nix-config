{pkgs, ...}: {
  home.packages = with pkgs; [
    jdk
    maven
    gradle
  ];
}
