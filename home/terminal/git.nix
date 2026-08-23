# Git configuration -- shared across all profiles.
# Reads user identity from kernix config.
{host, ...}: {
  programs.git = {
    enable = true;
    signing.format = "openpgp";
    settings = {
      user.name = host.git.name;
      user.email = host.git.email;
      core.editor = "nvim";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
