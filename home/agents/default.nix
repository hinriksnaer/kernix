# AI agents -- gateway auth and enablement CLIs.
#
# A CLI can't export into the parent shell, so these print export lines
# for eval:
#   eval "$(ai-auth)"        # ENMAAS_KEY from bitwarden
#   eval "$(claude-enable)"  # ANTHROPIC_* gateway flags (reads $ENMAAS_KEY)
{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "ai-auth";
      text = ''
        echo 'export ENMAAS_KEY="$(rbw get enmaas-key)"'
      '';
      # SC2016: $ENMAAS_KEY must stay literal -- it expands when the
      # user's shell evals the output, not in this script.
      excludeShellChecks = ["SC2016"];
    })

    (pkgs.writeShellApplication {
      name = "claude-enable";
      text = ''
        echo 'export ANTHROPIC_BASE_URL="https://api.enmaas.devshift.net"'
        echo 'export ANTHROPIC_API_KEY="$ENMAAS_KEY"'
        echo 'export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="1"'
      '';
      # SC2016: $ENMAAS_KEY must stay literal -- it expands when the
      # user's shell evals the output, not in this script.
      excludeShellChecks = ["SC2016"];
    })
  ];
}
