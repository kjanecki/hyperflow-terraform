resource "kubernetes_namespace" "workerpools-2" {
  metadata {
    labels = {
      monitoring-enabled: "true"
    }
    name = "workerpools-2"
  }
}

resource "helm_release" "nfs-pv-workerpools-2" {
  name             = "nfs-pv"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/nfs-storage.tgz"
  values           = [file("./values/nfs-volume-workerpools-2.yml")]
  depends_on       = [kubernetes_namespace.workerpools-2]
  namespace        = "workerpools-2"
}

resource "helm_release" "redis-workerpools-2" {
  name             = "redis"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/redis.tgz"
  values           = [file("./values/redis.yml")]
  depends_on       = [kubernetes_namespace.workerpools-2]
  namespace        = "workerpools-2"
}

resource "helm_release" "hyperflow-engine-workerpools-2" {
  name       = "hyperflow-engine-workerpools-2"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-engine.tgz"
  values     = [file("./values/hyperflow-engine-workerpools-2.yml")]
  depends_on = [
    kubernetes_namespace.workerpools-2, helm_release.nfs-pv-workerpools-2, helm_release.redis-workerpools-2,
    helm_release.monitoring, helm_release.adapter, helm_release.rabbitmq-metric-exporter, helm_release.rabbitmq
  ]
  namespace        = "workerpools-2"
}

resource "helm_release" "hyperflow-data-workerpools-2" {
  name             = "hyperflow-data"
  chart            = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hyperflow-nfs-data.tgz"
  values           = [file("./values/hyperflow-data.yml")]
  depends_on       = [kubernetes_namespace.workerpools-2, helm_release.hyperflow-engine-workerpools-2]
  namespace        = "workerpools-2"
}