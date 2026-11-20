# Core kernix options -- cross-cutting identity and preferences.
# These are read by multiple modules across system/ and home/.
# Feature-specific options are declared by each module's options.nix
# and aggregated by system/options.nix.
{lib, ...}:
with lib; {
  options.kernix = {
    # ── Identity ──
    username = mkOption {
      type = types.str;
      description = "System username for this host.";
    };

    gpu = mkOption {
      type = types.enum ["nvidia" "intel" "amd" "none"];
      default = "none";
      description = "GPU driver to use. Configures drivers, kernel modules, and VAAPI.";
    };

    # ── System ──
    timezone = mkOption {
      type = types.str;
      default = "America/New_York";
      description = "System timezone.";
    };

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "System locale.";
    };

    homePrefix = mkOption {
      type = types.str;
      default = "/home";
      description = "Home directory prefix (e.g. /home on Linux, /Users on macOS).";
    };

    kernixRoot = mkOption {
      type = types.str;
      default = "";
      description = "Override for the kernix config root directory. Empty to auto-derive.";
    };

    # ── Preferences (read by multiple HM and system modules) ──
    terminal = mkOption {
      type = types.enum ["ghostty" "kitty" "alacritty" "foot"];
      default = "ghostty";
      description = "Terminal emulator.";
    };

    defaultTheme = mkOption {
      type = types.str;
      default = "ayu";
      description = "Default theme (from themes/ or a built-in OpenCode theme).";
    };

    font = {
      monospace = mkOption {
        type = types.str;
        default = "Maple Mono NF";
        description = "Monospace font family.";
      };
    };

    git = {
      name = mkOption {
        type = types.str;
        default = "user";
        description = "Git author name for commits.";
      };
      email = mkOption {
        type = types.str;
        default = "user@localhost";
        description = "Git author email for commits.";
      };
    };

    # ── Agents ──
    # Off by default: the agent CLIs then use their own subscription/OAuth
    # login. Enabling it writes ANTHROPIC_BASE_URL and an apiKeyHelper into
    # ~/.claude/settings.json, which outranks that login (and, for Claude
    # Code, disables claude.ai connectors). See home/agents/default.nix.
    agents.claude.gateway = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Authenticate Claude Code through the EnMaaS gateway instead of its own login.";
      };
      url = mkOption {
        type = types.str;
        default = "https://api.enmaas.devshift.net";
        description = "Base URL of the EnMaaS Anthropic-compatible endpoint.";
      };
      keyItem = mkOption {
        type = types.str;
        default = "enmaas-key";
        description = "rbw item holding the EnMaaS API key.";
      };
    };

    # pi registers EnMaaS as a custom `enmaas` provider unconditionally; the
    # flags below only decide whether pi's *built-in* provider IDs are
    # redirected at the gateway. A redirected built-in provider is useless
    # with a subscription login, and pi prefers a stored auth.json credential
    # over a models.json apiKey -- so switching routeAnthropic on while an
    # Anthropic OAuth login is stored needs `/logout anthropic` first.
    # See home/agents/pi.nix.
    agents.pi.gateway = {
      url = mkOption {
        type = types.str;
        default = "https://api.enmaas.devshift.net";
        description = "Base URL of the EnMaaS gateway (no `/v1` suffix).";
      };
      keyItem = mkOption {
        type = types.str;
        default = "enmaas-key";
        description = "rbw item holding the EnMaaS API key.";
      };
      routeAnthropic = mkOption {
        type = types.bool;
        default = false;
        description = "Point pi's built-in anthropic provider at the EnMaaS gateway. Off leaves Claude models on pi's own login (`/login` -> Anthropic (Claude Pro/Max)), which bills as Claude extra usage rather than plan limits.";
      };
      routeOpenai = mkOption {
        type = types.bool;
        default = true;
        description = "Point pi's built-in openai provider at the EnMaaS gateway. Off leaves it on pi's own OpenAI login or OPENAI_API_KEY.";
      };
    };
  };
}
