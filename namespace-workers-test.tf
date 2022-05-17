resource "kubernetes_namespace" "workers-test" {
  metadata {
    labels = {
      monitoring-enabled: "true"
    }
    name = "workers-test"
  }
}

resource "helm_release" "nfs-pv-workers-test" {
  name             = "nfs-pv"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/nfs-storage.tgz"
  values           = [file("./values/nfs-volume.yml")]
  depends_on       = [kubernetes_namespace.workers-test]
  namespace        = "workers-test"
}

resource "helm_release" "redis-workers-test" {
  name             = "redis"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/redis.tgz"
  values           = [file("./values/redis.yml")]
  depends_on       = [kubernetes_namespace.workers-test]
  namespace        = "workers-test"
}

resource "helm_release" "hyperflow-engine-workers-test" {
  name       = "hyperflow-engine-workers-test"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-engine.tgz"
  values     = [file("./values/hyperflow-engine-workers-test.yml")]
  depends_on = [
    kubernetes_namespace.workers-test, helm_release.nfs-pv-workers-test, helm_release.redis-workers-test,
    helm_release.monitoring, helm_release.adapter, helm_release.rabbitmq-metric-exporter, helm_release.rabbitmq
  ]
  namespace        = "workers-test"
}

resource "helm_release" "hyperflow-data-workers-test" {
  name             = "hyperflow-data"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-nfs-data.tgz"
  values           = [file("./values/hyperflow-data.yml")]
  depends_on       = [kubernetes_namespace.workers-test, helm_release.hyperflow-engine-workers-test]
  namespace        = "workers-test"
}