# pi -- terminal AI coding agent (llm-agents.nix).
# Config lives in ~/.pi/
{pkgs, ...}: {
  home.packages = [pkgs.inputs'.llm-agents.pi];
}
