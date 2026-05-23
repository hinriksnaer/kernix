# IBM Cloud -- CLI tools for IBM Cloud and OpenShift.
{pkgs, ...}: {
  home.packages = with pkgs; [
    ibmcloud-cli
    openshift
  ];
}
