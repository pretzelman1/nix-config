{pkgs, ...}: {
  home.packages =
    (with pkgs; [
      nodejs_22
    ])
    ++ (with pkgs.nodePackages; [
      yarn
      typescript
      typescript-language-server
    ]);
}
