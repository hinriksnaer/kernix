# Claude Code CLI -- official Anthropic command-line tool for AI coding.
# Requires ANTHROPIC_API_KEY environment variable (set in shell profile).
# Vertex AI auth is handled by vertex-auth.nix module.
# Config stored in ~/.claude/
{pkgs, ...}: {
  home.packages = [pkgs.claude-code];
}
