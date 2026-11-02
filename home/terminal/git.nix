# Git configuration -- shared across all profiles.
# Reads user identity from kernix config.
{host, ...}: {
  programs.git = {
    enable = true;
    signing = {
      # SSH signing: the private key stays in the Bitwarden SSH agent,
      # only the public key is referenced here.
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElKeeeMEKZWfN/F8epaCe15KbynrclyhS/mPaiHkerV github";
      signByDefault = true;
      # Trust our own signing key locally so `git log --show-signature`
      # and `git verify-commit` can verify our commits.
      allowedSigners = "${host.git.email} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElKeeeMEKZWfN/F8epaCe15KbynrclyhS/mPaiHkerV github";
    };
    settings = {
      user.name = host.git.name;
      user.email = host.git.email;
      core.editor = "nvim";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
