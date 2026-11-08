# TradeSkillMaster Desktop App -- not in nixpkgs.
# Official Linux AppImage, pinned here (the vendor URL is versioned):
#   https://desktop-backend.tradeskillmaster.com/app-downloads/linux
#
# Unlike the old exceptionptr/tsm-app-linux port, this release understands
# WoW Forever and installs TradeSkillMaster_AppHelper into `_forever_`.
final: _prev: let
  pname = "tsm-desktop";
  version = "1.0.9";
  src = final.fetchurl {
    url = "https://tsm-desktop-app-builds-production.nyc3.cdn.digitaloceanspaces.com/versions/${version}/TradeSkillMaster.AppImage";
    hash = "sha256-I+NyXmZ7iSnZVpyhn6c2x4oKSTuz31ep4Ti5B46QPMs=";
  };

  # Reused by wrapType2 (same pname/version/src => same store path).
  contents = final.appimageTools.extract {inherit pname version src;};
in {
  tsm-desktop = final.appimageTools.wrapType2 {
    inherit pname version src;

    # The AppImage ships its own desktop entry (Exec=AppRun --no-sandbox) and
    # icon set. Point Exec at the wrapped binary and install the icons so
    # rofi/drun resolve them without relying on the AppImage directory.
    extraInstallCommands = ''
      install -Dm644 ${contents}/TradeSkillMaster.desktop \
        $out/share/applications/tsm-desktop.desktop
      substituteInPlace $out/share/applications/tsm-desktop.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' \
        "Exec=$out/bin/${pname} --no-sandbox %U"

      for size in 16 24 32 48 64 96 128 256 512 1024; do
        install -Dm644 \
          ${contents}/usr/share/icons/hicolor/''${size}x''${size}/apps/tradeskillmaster.png \
          $out/share/icons/hicolor/''${size}x''${size}/apps/tradeskillmaster.png
      done
    '';

    meta = {
      description = "TradeSkillMaster Desktop Application";
      homepage = "https://www.tradeskillmaster.com/";
      license = final.lib.licenses.unfreeRedistributable;
      platforms = ["x86_64-linux"];
      mainProgram = pname;
    };
  };
}
