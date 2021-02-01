resource "datadog_monitor" "datadog-up" {
  count   = var.enable-datadog ? 1 : 0
  name    = "DataDog is sending data for ${var.cluster-name}"
  type    = "service check"
  message = "DataDog has stopped sending data. Notify: ${var.datadog-notifier}"

  query = "'datadog.agent.up'.over('cluster_name:${var.cluster-name}').last(5).count_by_status()"

  notify_no_data    = true

  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["cluster_name:${var.cluster-name}"]
}

resource "datadog_monitor" "cluster-nodes-ready" {
  count   = var.enable-datadog ? 1 : 0
  name    = "Nodes are ready for ${var.cluster-name}"
  type    = "metric alert"
  message = "Nodes in ${var.cluster-name} are not ready. Notify: ${var.datadog-notifier}"

  query = "avg(last_10m):sum:kubernetes_state.nodes.by_condition{condition:ready,status:true,cluster_name:${var.cluster-name}} by {status,condition,cluster_name} < 3"

  notify_no_data    = true

  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["cluster_name:${var.cluster-name}"]
}

resource "datadog_monitor" "cluster-nodes-disk-pressure" {
  count   = var.enable-datadog ? 1 : 0
  name    = "Nodes are seeing disk pressure for ${var.cluster-name}"
  type    = "metric alert"
  message = "Nodes in ${var.cluster-name} are seeing disk pressure. Notify: ${var.datadog-notifier}"

  query = "avg(last_1h):sum:kubernetes_state.nodes.by_condition{condition:diskpressure,status:true,cluster_name:${var.cluster-name}} by {cluster_name} >= 1"

  notify_no_data    = true

  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["cluster_name:${var.cluster-name}"]
}

resource "datadog_monitor" "cluster-nodes-memory-pressure" {
  count   = var.enable-datadog ? 1 : 0
  name    = "Nodes are seeing memory pressure for ${var.cluster-name}"
  type    = "metric alert"
  message = "Nodes in ${var.cluster-name} are seeing memory pressure. Notify: ${var.datadog-notifier}"

  query = "avg(last_10m):sum:kubernetes_state.nodes.by_condition{condition:memorypressure,status:true,cluster_name:${var.cluster-name}} by {cluster_name} >= 1"

  notify_no_data    = true

  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["cluster_name:${var.cluster-name}"]
}

resource "datadog_monitor" "cluster-nodes-pid-pressure" {
  count   = var.enable-datadog ? 1 : 0
  name    = "Nodes are seeing pid pressure for ${var.cluster-name}"
  type    = "metric alert"
  message = "Nodes in ${var.cluster-name} are seeing pid pressure. Notify: ${var.datadog-notifier}"

  query = "avg(last_10m):sum:kubernetes_state.nodes.by_condition{condition:pidpressure,status:true,cluster_name:${var.cluster-name}} by {cluster_name} >= 1"

  notify_no_data    = true

  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["cluster_name:${var.cluster-name}"]
}

resource "datadog_monitor" "pending-pods" {
  count   = var.enable-datadog ? 1 : 0
  name    = "More pods are stuck in pending on ${var.cluster-name}"
  type    = "metric alert"
  message = "Pods on ${var.cluster-name} are increasingly stuck in pending phase. Notify: ${var.datadog-notifier}"

  query = "avg(last_1d):anomalies(sum:kubernetes_state.pod.status_phase{phase:pending,cluster_name:${var.cluster-name}} by {cluster_name}, 'agile', 2, direction='above', alert_window='last_1h', interval=300, count_default_zero='true', seasonality='daily') >= 1"

  notify_no_data      = false
  require_full_window = false

  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["cluster_name:${var.cluster-name}"]
}

resource "datadog_monitor" "failed-pods" {
  count   = var.enable-datadog ? 1 : 0
  name    = "More pods are failing on ${var.cluster-name}"
  type    = "metric alert"
  message = "Pods on ${var.cluster-name} are increasingly in the failing phase. Notify: ${var.datadog-notifier}"

  query = "avg(last_1d):anomalies(sum:kubernetes_state.pod.status_phase{phase:failed,cluster_name:${var.cluster-name}} by {cluster_name}, 'agile', 2, direction='above', alert_window='last_1h', interval=300, count_default_zero='true', seasonality='daily') >= 1"

  notify_no_data      = false
  require_full_window = false

  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["cluster_name:${var.cluster-name}"]
}

resource "datadog_monitor" "restarting-pods" {
  count   = var.enable-datadog ? 1 : 0
  name    = "Pods are repeatedly restarting on ${var.cluster-name}"
  type    = "metric alert"
  message = "Pods on ${var.cluster-name} are repeatedly restarting. Notify: ${var.datadog-notifier}"

  query = "avg(last_5m):avg:kubernetes.containers.restarts{cluster_name:${var.cluster-name}} by {cluster_name,kube_namespace,pod_name} >= 1"

  notify_no_data      = false
  require_full_window = false


  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["cluster_name:${var.cluster-name}"]
}
