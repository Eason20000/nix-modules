{
  llama-cpp,
  fetchFromGitHub,
  lib,
}:

llama-cpp.overrideAttrs (oldAttrs: {
  pname = "llama-cpp-turboquant";
  version = "10465";

  src = fetchFromGitHub {
    owner = "TheTom";
    repo = "llama-cpp-turboquant";
    tag = "feature-turboquant-kv-cache-b10465-fca3093";
    hash = "sha256-zrLzRA73d6I04x0fWGGiA8UsMqtIbPhVKp7juvnYjvI=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  npmDepsHash = "sha256-FHvd2bMvBc9EXrJEzu8EN78oUVSLcOKYCc0232V+L4A=";

  passthru = oldAttrs.passthru // {
    updateScript = null;
  };

  meta = oldAttrs.meta // {
    description = oldAttrs.meta.description + " (TurboQuant fork)";
    homepage = "https://github.com/TheTom/llama-cpp-turboquant";
  };

})
