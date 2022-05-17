resource "kubernetes_namespace" "jobs" {
  metadata {
    labels = {
      monitoring-enabled : true
    }
    name = "jobs"
  }
}

resource "helm_release" "nfs-pv-jobs" {
  name       = "nfs-pv"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/nfs-storage.tgz"
  values     = [file("./values/nfs-volume.yml")]
  depends_on = [kubernetes_namespace.jobs]
  namespace  = "jobs"
}

resource "helm_release" "redis-jobs" {
  name       = "redis"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/redis.tgz"
  values     = [file("./values/redis.yml")]
  depends_on = [kubernetes_namespace.jobs]
  namespace  = "jobs"
}

resource "helm_release" "hyperflow-engine-jobs" {
  name       = "hyperflow-engine-jobs"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-engine.tgz"
  values     = [file("./values/hyperflow-engine-jobs.yml")]
  depends_on = [
    kubernetes_namespace.jobs, helm_release.nfs-pv-jobs,
    helm_release.redis-jobs
  ]
  namespace = "jobs"
}

resource "helm_release" "hyperflow-data-jobs" {
  name       = "hyperflow-data"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-nfs-data.tgz"
  values     = [file("./values/hyperflow-data.yml")]
  depends_on = [kubernetes_namespace.jobs, helm_release.hyperflow-engine-jobs]
  namespace  = "jobs"
}