{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "mihomo-tui";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "potoo0";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-J80PbiPVfW7cG6Pz0/ihUdk7d6l6z+uEy9Y1DYKOFtc=";
  };

  cargoHash = "sha256-a9L1NlbA7+yS9/RDRzO99uBs6iFBSp5YHO2jtXC73iA=";

  preBuild = ''
    export RUSTFLAGS="--cfg tokio_unstable $RUSTFLAGS"
  '';

  doCheck = false;

  meta = with lib; {
    description = "A simple TUI dashboard for monitoring and managing Mihomo via its REST API";
    homepage = "https://github.com/potoo0/mihomo-tui";
    license = licenses.mit;
    mainProgram = "mihomo-tui";
    maintainers = with maintainers; [ ];
  };

}
