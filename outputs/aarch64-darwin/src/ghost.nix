{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `configLib.nixosSystem`, `configLib.colmenaSystem`, etc.
  inputs,
  lib,
  configVars,
  system,
  specialArgs,
  ...
} @ args: let
  name = "ghost";
in {
  # macOS's configuration
  darwinConfigurations.${name} = lib.custom.macosSystem (args
    // {
      inherit name;
    });
}
