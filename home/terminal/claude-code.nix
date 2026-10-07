# Claude Code CLI -- official Anthropic command-line tool for AI coding.
# Config stored in ~/.claude/
{pkgs, ...}: {
  home.packages = [pkgs.inputs'.llm-agents.claude-code];
}
