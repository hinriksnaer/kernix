# Electron 39 is marked EOL in nixpkgs but bitwarden-desktop still
# depends on it. Allow it until upstream migrates to a newer Electron.
_final: prev: {
  electron_39 = prev.electron_39.overrideAttrs (old: {
    meta = old.meta // {knownVulnerabilities = [];};
  });
}
