# OpenAI Codex CLI -- official OpenAI coding agent.
# Config lives in ~/.codex/. EnMaaS is registered as a custom model
# provider; auth comes from $ENMAAS_KEY (see `codex-enable` in
# home/agents/default.nix).
#
# EnMaaS exposes only the Responses API, which is Codex's sole supported
# wire protocol. No default `model` is pinned: pass one per run
# (`codex -m rits/deepseek-ai/DeepSeek-V4.1-Flash-1017`) or override any
# key ad hoc with `codex -c key=value`.
{pkgs, ...}: {
  home.packages = [pkgs.inputs'.llm-agents.codex];

  # Managed as an immutable HM symlink. Codex would otherwise rewrite this
  # file (e.g. project trust entries); keep such state in profiles or
  # `-c` overrides instead.
  home.file.".codex/config.toml".text = ''
    model_provider = "enmaas"
    # No default model: supply one per run, e.g.
    #   codex -m rits/deepseek-ai/DeepSeek-V4.1-Flash-1017
    # or uncomment and pin a model here.

    [model_providers.enmaas]
    name = "EnMaaS"
    base_url = "https://api.enmaas.devshift.net/v1"
    env_key = "ENMAAS_KEY"
    wire_api = "responses"
  '';
}
