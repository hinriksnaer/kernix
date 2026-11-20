# pi -- terminal AI coding agent (llm-agents.nix).
# Config lives in ~/.pi/. EnMaaS is registered as a custom `enmaas` provider
# (OpenAI-compatible, key resolved from rbw at request time). kernix.agents.pi
# .gateway.route{Anthropic,Openai} decide whether the *built-in* provider IDs
# also point at the gateway; with routeAnthropic off, Claude models come from
# pi's own login (`/login` -> Anthropic (Claude Pro/Max)) instead.
#
# models.json is managed as an immutable HM symlink, like ~/.codex/config.toml:
# pi only reads it (mutable state lives in settings.json, auth.json and
# models-store.json), so edit this module rather than the file.
{
  pkgs,
  host,
  lib,
  ...
}: let
  gateway = host.agents.pi.gateway;
  apiKey = "!rbw get ${gateway.keyItem}";
  v1 = "${gateway.url}/v1";

  enmaasModels = [
    {
      id = "rits/zai-org/glm-5-3";
      name = "GLM 5.3 (EnMaaS)";
      reasoning = true;
      input = ["text"];
      contextWindow = 262144;
      maxTokens = 65536;
      cost = {
        input = 0;
        output = 0;
        cacheRead = 0;
        cacheWrite = 0;
      };
      compat.supportsDeveloperRole = false;
      samplingParams = {
        frequency_penalty = 0;
        presence_penalty = 0;
      };
    }
    {
      id = "rits/deepseek-ai/DeepSeek-V4.1-Flash-1017";
      name = "DeepSeek V4.1 Flash (EnMaaS)";
      reasoning = true;
      input = ["text" "image"];
      contextWindow = 1048576;
      maxTokens = 262144;
      cost = {
        input = 0;
        output = 0;
        cacheRead = 0;
        cacheWrite = 0;
      };
      compat.supportsDeveloperRole = false;
      samplingParams = {
        frequency_penalty = 0;
        presence_penalty = 0;
      };
    }
  ];

  providers =
    {
      enmaas = {
        baseUrl = v1;
        api = "openai-completions";
        inherit apiKey;
        models = enmaasModels;
      };
    }
    // lib.optionalAttrs gateway.routeOpenai {
      openai = {
        baseUrl = v1;
        inherit apiKey;
      };
    }
    // lib.optionalAttrs gateway.routeAnthropic {
      anthropic = {
        baseUrl = gateway.url;
        inherit apiKey;
      };
    };
in {
  home.packages = [pkgs.inputs'.llm-agents.pi];

  home.file.".pi/agent/models.json".source = (pkgs.formats.json {}).generate "pi-models.json" {
    "$schema" = "https://pi.dev/schemas/models.schema.json";
    inherit providers;
  };
}
