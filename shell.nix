with (import <nixpkgs> {});

mkShell {
  name = "consulkit";

  buildInputs = [
    ruby
    bundler
    rubocop
  ];

  shellHook = ''
    bin/setup
  '';
}
