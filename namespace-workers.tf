resource "kubernetes_namespace" "workers" {
  metadata {
    labels = {
      monitoring-enabled: "true"
    }
    name = "workers"
  }
}

resource "helm_release" "nfs-pv-workers" {
  name             = "nfs-pv"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/nfs-storage.tgz"
  values           = [file("./values/nfs-volume.yml")]
  namespace        = "workers"
}

resource "helm_release" "redis-workers" {
  name             = "redis"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/redis.tgz"
  values           = [file("./values/redis.yml")]
  depends_on       = [kubernetes_namespace.workers]
  namespace        = "workers"
}

resource "helm_release" "hyperflow-engine-workers" {
  name       = "hyperflow-engine-workers"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-engine.tgz"
  values     = [file("./values/hyperflow-engine-workers.yml")]
  depends_on = [
    kubernetes_namespace.workers, helm_release.nfs-pv-workers, helm_release.redis-workers,
    helm_release.monitoring, helm_release.adapter, helm_release.rabbitmq-metric-exporter, helm_release.rabbitmq
  ]
  namespace        = "workers"
}

resource "helm_release" "hyperflow-data-workers" {
  name             = "hyperflow-data"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-nfs-data.tgz"
  values           = [file("./values/hyperflow-data.yml")]
  depends_on       = [kubernetes_namespace.workers, helm_release.hyperflow-engine-workers]
  namespace        = "workers"
}