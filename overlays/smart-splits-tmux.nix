# Tmux half of smart-splits.nvim v3 -- not in nixpkgs.
# Source pinned by flake.lock; update with:
#   nix flake update smart-splits-backend-tmux
{
  inputs,
}: final: prev: {
  tmuxPlugins =
    prev.tmuxPlugins
    // {
      smart-splits = prev.tmuxPlugins.mkTmuxPlugin {
        pluginName = "smart-splits";
        rtpFilePath = "smart-splits.tmux";
        version = inputs.smart-splits-backend-tmux.shortRev or "master";
        src = inputs.smart-splits-backend-tmux;
      };
    };
}
