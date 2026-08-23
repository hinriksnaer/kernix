# Vertex AI authentication for Anthropic Claude via Google Cloud.
# Configures environment variables and installs gcloud SDK when vertexProject is set.
# Used by: opencode, claude-code, and other AI tools.
{
  pkgs,
  lib,
  host,
  ...
}: let
  oc = host.opencode;
  hasVertex = oc.vertexProject != "";
in {
  # Install Google Cloud SDK only if Vertex AI is configured
  home.packages = lib.optionals hasVertex [pkgs.google-cloud-sdk];

  # Set environment variables for Anthropic Vertex AI integration
  home.sessionVariables = lib.optionalAttrs hasVertex {
    CLAUDE_CODE_USE_VERTEX = "1";
    ANTHROPIC_VERTEX_PROJECT_ID = oc.vertexProject;
    GOOGLE_CLOUD_PROJECT = oc.vertexProject;
    CLOUD_ML_REGION = oc.cloudMlRegion;
    VERTEX_LOCATION = oc.cloudMlRegion;
  };
}
