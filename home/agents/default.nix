# AI agents -- agent CLIs, gateway auth, and enablement helpers.
#
# A CLI can't export into the parent shell, so these print export lines
# for eval:
#   eval "$(ai-auth)"        # ENMAAS_KEY from bitwarden
#   eval "$(claude-enable)"  # ANTHROPIC_* gateway flags (reads $ENMAAS_KEY)
#   eval "$(codex-enable)"   # ENMAAS_KEY for Codex's EnMaaS provider
#
# The helpers are opt-in: nothing runs them for you.
#
# Claude Code's EnMaaS settings (gateway URL + apiKeyHelper) are merged into
# ~/.claude/settings.json by activation only when
# kernix.agents.claude.gateway.enable is set. The merge is gated because a
# custom base URL or an API key helper outranks the OAuth login -- which is
# what makes `claude` ignore the subscription and disables claude.ai
# connectors. With the gateway off, activation instead removes the keys it
# wrote, so switching back to the subscription login needs no manual edit of
# the file.
{
  pkgs,
  config,
  lib,
  host,
  ...
}: let
  gateway = host.agents.claude.gateway;
  helper = "${pkgs.rbw}/bin/rbw get ${gateway.keyItem}";
in {
  imports = [
    ./pi.nix
    ./claude-code.nix
    ./opencode.nix
    #./codex.nix
  ];

  config = lib.mkMerge [
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "ai-auth";
          text = ''
            echo 'export ENMAAS_KEY="$(rbw get ${gateway.keyItem})"'
          '';
          # SC2016: $ENMAAS_KEY must stay literal -- it expands when the
          # user's shell evals the output, not in this script.
          excludeShellChecks = ["SC2016"];
        })

        (pkgs.writeShellApplication {
          name = "claude-enable";
          text = ''
            echo 'export ANTHROPIC_BASE_URL="${gateway.url}"'
            echo 'export ANTHROPIC_API_KEY="$ENMAAS_KEY"'
            echo 'export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="1"'
          '';
          # SC2016: $ENMAAS_KEY must stay literal -- it expands when the
          # user's shell evals the output, not in this script.
          excludeShellChecks = ["SC2016"];
        })

        (pkgs.writeShellApplication {
          name = "codex-enable";
          text = ''
            echo 'export ENMAAS_KEY="$(rbw get ${gateway.keyItem})"'
          '';
          # SC2016: $() must stay literal -- it runs when the user's shell
          # evals the output, not in this script.
          excludeShellChecks = ["SC2016"];
        })
      ];
    }

    # Merge EnMaaS settings into Claude Code's user settings instead of
    # owning the whole file: theme/tui/model keys are written by Claude
    # itself and must stay mutable. apiKeyHelper keeps the key out of the
    # Nix store.
    (lib.mkIf gateway.enable {
      home.activation.claudeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
        settings="${config.home.homeDirectory}/.claude/settings.json"
        mkdir -p "$(dirname "$settings")"
        if [ -f "$settings" ]; then
          ${pkgs.jq}/bin/jq --indent 2 \
            '.env = ((.env // {}) + {
              "ANTHROPIC_BASE_URL": "${gateway.url}",
              "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY": "1"
            }) | .apiKeyHelper = "${helper}"' \
            "$settings" > "$settings.tmp"
          mv "$settings.tmp" "$settings"
        else
          printf '%s\n' '{
            "apiKeyHelper": "${helper}",
            "env": {
              "ANTHROPIC_BASE_URL": "${gateway.url}",
              "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY": "1"
            }
          }' > "$settings"
        fi
      '';
    })

    # Gateway off: undo a merge from an earlier activation. Only the values
    # this module writes are touched, so a helper or base URL set by hand
    # survives.
    (lib.mkIf (!gateway.enable) {
      home.activation.claudeSettingsRemove = lib.hm.dag.entryAfter ["writeBoundary"] ''
        settings="${config.home.homeDirectory}/.claude/settings.json"
        if [ -f "$settings" ]; then
          ${pkgs.jq}/bin/jq --indent 2 \
            --arg helper "${helper}" \
            --arg url "${gateway.url}" \
            'if .apiKeyHelper == $helper then del(.apiKeyHelper) else . end
             | if .env.ANTHROPIC_BASE_URL? == $url then del(.env.ANTHROPIC_BASE_URL) else . end
             | del(.env.CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY)
             | if (.env | type) == "object" and (.env | length) == 0 then del(.env) else . end' \
            "$settings" > "$settings.tmp"
          mv "$settings.tmp" "$settings"
        fi
      '';
    })
  ];
}
