resource "helm_release" "monitoring" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  values     = [file("./values/prometheus.yml")]
}

resource "helm_release" "adapter" {
  name       = "adapter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-adapter"
  values     = [file("./values/prometheus-adapter.yml")]
  depends_on = [
    helm_release.monitoring
  ]
}

resource "helm_release" "rabbitmq" {
  name       = "rabbitmq"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  values     = [file("./values/rabbitmq.yml")]
  version    = "8.21.0"
  depends_on = [
    helm_release.monitoring
  ]
}

resource "helm_release" "rabbitmq-metric-exporter" {
  name       = "rabbitmq-metric-exporter"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/rabbitmq-metric-exporter.tgz"
  values     = [file("./values/rabbitmq-metric-exporter.yml")]
  depends_on = [
    helm_release.monitoring,
    helm_release.rabbitmq
  ]
}

resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  namespace  = "default"
  values     = [file("./values/keda.yml")]
  chart      = "keda"
  depends_on = [
    helm_release.monitoring,
    helm_release.rabbitmq-metric-exporter
  ]
}

resource "helm_release" "hflow-worker-operator" {
  name       = "hflow-worker-operator"
  chart      = "https://github.com/kjanecki/hyperflow-charts/releases/download/v1.0.0/hflow-worker-operator.tgz"
  values     = [file("./values/hyperflow-worker-operator.yml")]
  depends_on = [
    helm_release.monitoring,
    helm_release.rabbitmq-metric-exporter, helm_release.keda
  ]
}


