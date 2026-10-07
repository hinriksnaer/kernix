# Claude Code CLI -- official Anthropic command-line tool for AI coding.
# Config stored in ~/.claude/
{
  pkgs,
  lib,
  hostname,
  ...
}: {
  home.packages = [pkgs.inputs'.llm-agents.claude-code];

  # Route Claude Code through the enMAAS gateway (remote host only).
  # ANTHROPIC_API_KEY stays a $VAR reference -- HM writes session vars
  # double-quoted, so the key resolves from the environment at shell
  # startup (ENMAAS_KEY must be set there) and never enters the store.
  home.sessionVariables = lib.mkIf (hostname == "remote") {
    ANTHROPIC_BASE_URL = "https://api.enmaas.devshift.net";
    ANTHROPIC_API_KEY = "$ENMAAS_KEY";
    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = "1";
  };
}
