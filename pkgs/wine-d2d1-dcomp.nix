{
  wineWow64Packages,
  fetchFromGitHub,
}:

wineWow64Packages.stableFull.overrideAttrs (old: {
  pname = "wine-d2d1-dcomp";
  version = "11.0-d2d1-dcomp";

  src = fetchFromGitHub {
    owner = "giang17";
    repo = "wine";
    rev = "7756d59703415b6390a333c22afb6b018d7f7668";
    hash = "sha256-cg+E9eyYmVUemhIRixBq8SMXoUNAfsd6wq11S7yOfx0=";
  };

  passthru = old.passthru // {
    updateScript = null;
  };

  meta = old.meta // {
    description = "Wine fork with DirectComposition/Direct2D for Windows audio software";
    homepage = "https://github.com/giang17/wine";
  };
})
