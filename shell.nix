with (import <nixpkgs> {});
let
  # gems = bundlerEnv {
  #   name   = "consulkit";
  #   gemdir = ./.;

  #   inherit ruby;
  # };
in stdenv.mkDerivation {
  name = "consulkit";

  buildInputs = [
    #gems
    ruby
    bundler
    rubocop
  ];
}
