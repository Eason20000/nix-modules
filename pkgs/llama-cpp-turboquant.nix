{
  llama-cpp,
  fetchFromGitHub,
  lib,
}:

llama-cpp.overrideAttrs (oldAttrs: {
  pname = "llama-cpp-turboquant";
  version = "9608";

  src = fetchFromGitHub {
    owner = "TheTom";
    repo = "llama-cpp-turboquant";
    rev = "4595fff0bbd15ee01663699b788eea70e7e1cd69";
    hash = "sha256-QLUzw1Dk0JmFjcQ8cbQQu0z6/eo0Nhk01QXHYd0AzUA=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  npmDepsHash = "sha256-TU4Gv+dd48WDpswhfVtm79IVIOwoCXz1fZ/DI/z40Wg=";

  passthru = oldAttrs.passthru // {
    updateScript = null;
  };

  meta = oldAttrs.meta // {
    description = oldAttrs.meta.description + " (TurboQuant fork)";
    homepage = "https://github.com/TheTom/llama-cpp-turboquant";
  };
})
