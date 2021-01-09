data "google_project" "current" {
}

resource "google_pubsub_topic" "topic" {
  name = "taskhawk-${var.queue}"

  labels = var.labels
}

data "google_iam_policy" "topic_policy" {
  dynamic "binding" {
    for_each = var.iam_service_accounts

    content {
      members = ["serviceAccount:${binding.value}"]
      role    = "roles/pubsub.publisher"
    }
  }

  dynamic "binding" {
    for_each = var.iam_service_accounts

    content {
      members = ["serviceAccount:${binding.value}"]
      role    = "roles/pubsub.viewer"
    }
  }
}

resource "google_pubsub_topic_iam_policy" "topic_policy" {
  count = length(var.iam_service_accounts) == 0 ? 0 : 1

  policy_data = data.google_iam_policy.topic_policy.policy_data
  topic       = google_pubsub_topic.topic.name
}

resource "google_pubsub_subscription" "subscription" {
  name  = "taskhawk-${var.queue}"
  topic = google_pubsub_topic.topic.name

  ack_deadline_seconds = 20

  labels = var.labels

  expiration_policy {
    ttl = ""
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dlq_topic.id
    max_delivery_attempts = 5
  }
}

data "google_iam_policy" "subscription_policy" {
  dynamic "binding" {
    for_each = var.iam_service_accounts

    content {
      members = ["serviceAccount:${binding.value}"]
      role    = "roles/pubsub.subscriber"
    }
  }

  dynamic "binding" {
    for_each = var.iam_service_accounts

    content {
      members = ["serviceAccount:${binding.value}"]
      role    = "roles/pubsub.viewer"
    }
  }

  binding {
    members = [
      "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
    ]
    role = "roles/pubsub.subscriber"
  }

  binding {
    members = [
      "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
    ]
    role = "roles/pubsub.viewer"
  }
}

resource "google_pubsub_subscription_iam_policy" "subscription_policy" {
  count = length(var.iam_service_accounts) == 0 ? 0 : 1

  policy_data  = data.google_iam_policy.subscription_policy.policy_data
  subscription = google_pubsub_subscription.subscription.name
}

resource "google_pubsub_topic" "dlq_topic" {
  name = "taskhawk-${var.queue}-dlq"

  labels = var.labels
}

data "google_iam_policy" "dlq_topic_policy" {
  dynamic "binding" {
    for_each = var.iam_service_accounts

    content {
      members = ["serviceAccount:${binding.value}"]
      role    = "roles/pubsub.publisher"
    }
  }

  dynamic "binding" {
    for_each = var.iam_service_accounts

    content {
      members = ["serviceAccount:${binding.value}"]
      role    = "roles/pubsub.viewer"
    }
  }

  binding {
    members = [
      "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
    ]
    role = "roles/pubsub.publisher"
  }

  binding {
    members = [
      "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
    ]
    role = "roles/pubsub.viewer"
  }
}

resource "google_pubsub_topic_iam_policy" "dlq_topic_policy" {
  count = length(var.iam_service_accounts) == 0 ? 0 : 1

  policy_data = data.google_iam_policy.dlq_topic_policy.policy_data
  topic       = google_pubsub_topic.dlq_topic.name
}

resource "google_pubsub_subscription" "dlq_subscription" {
  name  = "taskhawk-${var.queue}-dlq"
  topic = google_pubsub_topic.dlq_topic.name

  ack_deadline_seconds = 20

  labels = var.labels

  expiration_policy {
    ttl = ""
  }
}

data "google_iam_policy" "dlq_subscription_policy" {
  dynamic "binding" {
    for_each = var.iam_service_accounts

    content {
      members = ["serviceAccount:${binding.value}"]
      role    = "roles/pubsub.subscriber"
    }
  }

  dynamic "binding" {
    for_each = var.iam_service_accounts

    content {
      members = ["serviceAccount:${binding.value}"]
      role    = "roles/pubsub.viewer"
    }
  }
}

resource "google_pubsub_subscription_iam_policy" "dlq_subscription_policy" {
  count = length(var.iam_service_accounts) == 0 ? 0 : 1

  policy_data  = data.google_iam_policy.dlq_subscription_policy.policy_data
  subscription = google_pubsub_subscription.dlq_subscription.name
}

resource "google_monitoring_alert_policy" "high_message_alert" {
  count = var.enable_alerts ? 1 : 0

  project = var.alerting_project

  display_name = "${title(var.queue)} Taskhawk queue message count too high${local.title_suffix}"
  combiner     = "OR"

  conditions {
    display_name = "${title(var.queue)} Taskhawk queue message count too high${local.title_suffix}"

    condition_threshold {
      threshold_value = var.queue_alarm_high_message_count_threshold // Number of messages
      comparison      = "COMPARISON_GT"
      duration        = "300s" // Seconds

      filter = "metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\" resource.type=\"pubsub_subscription\" resource.label.\"subscription_id\"=\"${google_pubsub_subscription.subscription.name}\"${local.filter_suffix}"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.queue_high_message_count_notification_channels
}

resource "google_monitoring_alert_policy" "dlq_alert" {
  count = var.enable_alerts ? 1 : 0

  project = var.alerting_project

  display_name = "${title(var.queue)} Taskhawk DLQ is non-empty${local.title_suffix}"
  combiner     = "OR"

  conditions {
    display_name = "${title(var.queue)} Taskhawk DLQ is non-empty${local.title_suffix}"

    condition_threshold {
      threshold_value = "1" // Number of messages
      comparison      = "COMPARISON_GT"
      duration        = "60s" // Seconds

      filter = "metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\" resource.type=\"pubsub_subscription\" resource.label.\"subscription_id\"=\"${google_pubsub_subscription.dlq_subscription.name}\"${local.filter_suffix}"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.dlq_high_message_count_notification_channels
}

data "google_client_config" "current" {
}

resource "google_dataflow_job" "firehose" {
  count = var.enable_firehose_all_messages ? 1 : 0

  name              = "${google_pubsub_topic.topic.name}-firehose"
  temp_gcs_location = var.dataflow_tmp_gcs_location
  template_gcs_path = var.dataflow_template_gcs_path

  lifecycle {
    # Google templates add their own labels so ignore changes
    ignore_changes = [labels]
  }

  zone   = var.dataflow_zone
  region = var.dataflow_region

  parameters = {
    inputTopic           = "projects/${data.google_client_config.current.project}/topics/${google_pubsub_topic.topic.name}"
    outputDirectory      = var.dataflow_output_directory
    outputFilenamePrefix = var.dataflow_output_filename_prefix == "" ? format("%s-", google_pubsub_topic.topic.name) : var.dataflow_output_filename_prefix
  }
}

resource "google_monitoring_alert_policy" "dataflow_freshness" {
  count = var.enable_firehose_all_messages && var.enable_alerts ? 1 : 0

  project = var.alerting_project

  display_name = "${title(var.queue)} Taskhawk Dataflow data freshness too stale${local.title_suffix}"
  combiner     = "OR"

  conditions {
    display_name = "Dataflow data age for ${google_dataflow_job.firehose[0].name}${local.title_suffix}"

    condition_threshold {
      threshold_value = var.dataflow_freshness_alert_threshold // Freshness is seconds
      comparison      = "COMPARISON_GT"
      duration        = "60s" // Seconds

      filter = "metric.type=\"dataflow.googleapis.com/job/data_watermark_age\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${google_dataflow_job.firehose[0].name}\"${local.dataflow_filter_suffix}"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_MAX"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.dataflow_freshness_alert_notification_channels
}

data "template_file" "data" {
  for_each = {for job_config in var.scheduler_jobs: job_config.name => job_config}

  template = file("${path.module}/data.${each.value.format_version == "" ? "v1.0" : each.value.format_version}.tpl")

  vars = {
    headers = jsonencode(each.value.headers)
    task    = each.value.task
    args    = jsonencode(each.value.args)
    kwargs  = jsonencode(each.value.kwargs)
  }
}

resource "google_cloud_scheduler_job" "job" {
  for_each = {for job_config in var.scheduler_jobs: job_config.name => job_config}

  name        = "taskhawk-${var.queue}-${replace(each.key, "_", "-")}"
  description = each.value.description
  schedule    = each.value.schedule
  time_zone   = each.value.timezone

  pubsub_target {
    topic_name = google_pubsub_topic.topic.id
    data = base64encode(data.template_file.data[each.key].rendered)
  }
}
