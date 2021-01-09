module "queue_default" {
  source = "./modules/queue"

  queue = var.queue

  enable_alerts        = var.enable_alerts
  labels               = var.labels
  iam_service_accounts = var.iam_service_accounts

  alerting_project                               = var.alerting_project
  queue_alarm_high_message_count_threshold       = var.queue_alarm_high_message_count_threshold
  queue_high_message_count_notification_channels = var.queue_high_message_count_notification_channels
  dlq_high_message_count_notification_channels   = var.dlq_high_message_count_notification_channels

  enable_firehose_all_messages    = var.enable_firehose_all_messages
  dataflow_tmp_gcs_location       = var.dataflow_tmp_gcs_location
  dataflow_template_gcs_path      = var.dataflow_template_gcs_path
  dataflow_zone                   = var.dataflow_zone
  dataflow_region                 = var.dataflow_region
  dataflow_output_directory       = var.dataflow_output_directory
  dataflow_output_filename_prefix = var.dataflow_output_filename_prefix

  scheduler_jobs = var.scheduler_jobs
}

module "queue_high_priority" {
  source = "./modules/queue"

  queue = "${var.queue}-high-priority"

  enable_alerts        = var.enable_alerts
  labels               = var.labels
  iam_service_accounts = var.iam_service_accounts

  alerting_project                               = var.alerting_project
  queue_alarm_high_message_count_threshold       = var.queue_alarm_high_priority_high_message_count_threshold
  queue_high_message_count_notification_channels = var.queue_high_message_count_notification_channels
  dlq_high_message_count_notification_channels   = var.dlq_high_message_count_notification_channels

  enable_firehose_all_messages    = var.enable_firehose_all_messages
  dataflow_tmp_gcs_location       = var.dataflow_tmp_gcs_location
  dataflow_template_gcs_path      = var.dataflow_template_gcs_path
  dataflow_zone                   = var.dataflow_zone
  dataflow_region                 = var.dataflow_region
  dataflow_output_directory       = var.dataflow_output_directory
  dataflow_output_filename_prefix = var.dataflow_output_filename_prefix
}

module "queue_low_priority" {
  source = "./modules/queue"

  queue = "${var.queue}-low-priority"

  enable_alerts        = var.enable_alerts
  labels               = var.labels
  iam_service_accounts = var.iam_service_accounts

  alerting_project                               = var.alerting_project
  queue_alarm_high_message_count_threshold       = var.queue_alarm_low_priority_high_message_count_threshold
  queue_high_message_count_notification_channels = var.queue_high_message_count_notification_channels
  dlq_high_message_count_notification_channels   = var.dlq_high_message_count_notification_channels

  enable_firehose_all_messages    = var.enable_firehose_all_messages
  dataflow_tmp_gcs_location       = var.dataflow_tmp_gcs_location
  dataflow_template_gcs_path      = var.dataflow_template_gcs_path
  dataflow_zone                   = var.dataflow_zone
  dataflow_region                 = var.dataflow_region
  dataflow_output_directory       = var.dataflow_output_directory
  dataflow_output_filename_prefix = var.dataflow_output_filename_prefix
}

module "queue_bulk" {
  source = "./modules/queue"

  queue = "${var.queue}-bulk"

  enable_alerts        = var.enable_alerts
  labels               = var.labels
  iam_service_accounts = var.iam_service_accounts

  alerting_project                               = var.alerting_project
  queue_alarm_high_message_count_threshold       = var.queue_alarm_bulk_high_message_count_threshold
  queue_high_message_count_notification_channels = var.queue_high_message_count_notification_channels
  dlq_high_message_count_notification_channels   = var.dlq_high_message_count_notification_channels

  enable_firehose_all_messages    = var.enable_firehose_all_messages
  dataflow_tmp_gcs_location       = var.dataflow_tmp_gcs_location
  dataflow_template_gcs_path      = var.dataflow_template_gcs_path
  dataflow_zone                   = var.dataflow_zone
  dataflow_region                 = var.dataflow_region
  dataflow_output_directory       = var.dataflow_output_directory
  dataflow_output_filename_prefix = var.dataflow_output_filename_prefix
}
