provider "helm" {
  kubernetes {
    config_path = "~/.kube/hyperflow-k8s"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/hyperflow-k8s"
}