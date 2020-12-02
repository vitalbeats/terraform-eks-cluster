resource "datadog_monitor" "datadog-up" {
  name               = "DataDog is sending data for ${var.cluster-name}"
  type               = "service check"
  message            = "DataDog has stopped sending data. Notify: @devops"

  query = "'datadog.agent.up'.over(cluster_name:${var.cluster-name}).last(5).count_by_status()"

  notify_no_data    = true

  lifecycle {
    ignore_changes = [silenced]
  }

  tags = ["cluster_name:${var.cluster-name}"]
}