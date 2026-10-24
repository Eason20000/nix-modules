{
  lib,
  rustPlatform,
  fetchFromGitHub,
  git,
}:

rustPlatform.buildRustPackage rec {
  pname = "mihomo-tui";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "potoo0";
    repo = pname;
    rev = "v${version}";
    leaveDotGit = true;
    hash = "sha256-fUVvukyo780uFHwCeFfUNtfwrgIFBb7E62RPz/5YWT8=";
  };

  cargoLock.lockFile = src + "/Cargo.lock";

  nativeBuildInputs = [ git ];

  RUSTFLAGS = "--cfg tokio_unstable";

  meta = with lib; {
    description = "A simple TUI dashboard for monitoring and managing Mihomo via its REST API";
    homepage = "https://github.com/potoo0/mihomo-tui";
    license = licenses.mit;
    mainProgram = "mihomo-tui";
    maintainers = with maintainers; [ ];
  };

}
