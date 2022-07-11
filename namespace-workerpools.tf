resource "kubernetes_namespace" "workerpools" {
  metadata {
    labels = {
      monitoring-enabled: "true"
    }
    name = "workerpools"
  }
}

resource "helm_release" "nfs-pv-workerpools" {
  name             = "nfs-pv"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/nfs-storage.tgz"
  values           = [file("./values/nfs-volume-workerpools.yml")]
  depends_on       = [kubernetes_namespace.workerpools]
  namespace        = "workerpools"
}

resource "helm_release" "redis-workerpools" {
  name             = "redis"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/redis.tgz"
  values           = [file("./values/redis.yml")]
  depends_on       = [kubernetes_namespace.workerpools]
  namespace        = "workerpools"
}

resource "helm_release" "hyperflow-engine-workerpools" {
  name       = "hyperflow-engine-workerpools"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-engine.tgz"
  values     = [file("./values/hyperflow-engine-workerpools.yml")]
  depends_on = [
    kubernetes_namespace.workerpools, helm_release.nfs-pv-workerpools, helm_release.redis-workerpools,
    helm_release.monitoring, helm_release.adapter, helm_release.rabbitmq-metric-exporter, helm_release.rabbitmq
  ]
  namespace        = "workerpools"
}

resource "helm_release" "hyperflow-data-workerpools" {
  name             = "hyperflow-data"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-nfs-data.tgz"
  values           = [file("./values/hyperflow-data.yml")]
  depends_on       = [kubernetes_namespace.workerpools, helm_release.hyperflow-engine-workerpools]
  namespace        = "workerpools"
}