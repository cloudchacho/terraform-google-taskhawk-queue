variable "queue" {
  description = "Application queue name (e.g. dev-myapp); unique across your infra"
}

variable "labels" {
  description = "Labels to attach to the PubSub topic and subscription"
  type        = map(string)
}

variable "enable_alerts" {
  description = "Should Stackdriver alerts be generated?"
  type        = bool
  default     = false
}

variable "enable_firehose_all_messages" {
  description = "Should all messages published to this topic be firehosed into Cloud Storage"
  default     = "false"
}

variable "dataflow_tmp_gcs_location" {
  description = "A gs bucket location for storing temporary files by Google Dataflow, e.g. gs://myBucket/tmp"
  default     = ""
}

variable "dataflow_template_gcs_path" {
  description = "The template path for Google Dataflow for PubSub to Storage, e.g. gs://dataflow-templates/2019-04-24-00/Cloud_PubSub_to_GCS_Text"
  default     = "gs://dataflow-templates/2019-04-24-00/Cloud_PubSub_to_GCS_Text"
}

variable "dataflow_zone" {
  description = "The zone to use for Dataflow. This may be required if it's not set at the provider level, or that zone doesn't support Dataflow regional endpoints (see https://cloud.google.com/dataflow/docs/concepts/regional-endpoints)"
  default     = ""
}

variable "dataflow_region" {
  description = "The region to use for Dataflow. This may be required if it's not set at the provider level, or you want to use a region different from the zone (see https://cloud.google.com/dataflow/docs/concepts/regional-endpoints)"
  default     = ""
}

variable "dataflow_output_directory" {
  description = "A gs bucket location for storing output files by Google Dataflow, e.g. gs://myBucket/taskhawkBackup"
  default     = ""
}

variable "dataflow_output_filename_prefix" {
  description = "Filename prefix for output files by Google Dataflow (defaults to subscription name)"
  default     = ""
}

variable "queue_alarm_high_message_count_threshold" {
  description = "Threshold for alerting on high message count in main queue"
  default     = 5000
}

variable "queue_alarm_high_priority_high_message_count_threshold" {
  description = "Threshold for alerting on high message count in high priority queue"
  default     = 5000
}

variable "queue_alarm_low_priority_high_message_count_threshold" {
  description = "Threshold for alerting on high message count in low priority queue"
  default     = 5000
}

variable "queue_alarm_bulk_high_message_count_threshold" {
  description = "Threshold for alerting on high message count in bulk queue"
  default     = 5000
}

variable "queue_alarm_test_duration_s" {
  description = "The duration for testing for alerting on high message count in main queue (defaults to 5 minutes)"
  default     = ""
}

variable "queue_alarm_high_priority_test_duration_s" {
  description = "The duration for testing for alerting on high message count in high priority queue (defaults to 5 minutes)"
  default     = ""
}

variable "queue_alarm_low_priority_test_duration_s" {
  description = "The duration for testing for alerting on high message count in low priority queue (defaults to 5 minutes)"
  default     = ""
}

variable "queue_alarm_bulk_test_duration_s" {
  description = "The duration for testing for alerting on high message count in bulk queue (defaults to 5 minutes)"
  default     = ""
}

variable "queue_high_message_count_notification_channels" {
  description = "Stackdriver Notification Channels for main queue alarm for high message count (required if alerting is on)"
  type        = list(string)
  default     = []
}

variable "dlq_high_message_count_notification_channels" {
  description = "Stackdriver Notification Channels for DLQ alarm for high message count (required if alerting is on)"
  type        = list(string)
  default     = []
}

variable "alerting_project" {
  description = "The project where alerting resources should be created (defaults to current project)"
  default     = ""
}

variable "iam_service_accounts" {
  description = "The IAM service accounts to create exclusive IAM permissions for this topic and subscription"
  default     = []
}

variable "dataflow_freshness_alert_threshold" {
  description = "Threshold for alerting on Dataflow freshness in seconds"
  default     = 1800 # 30 mins
}

variable "dataflow_freshness_alert_notification_channels" {
  description = "Stackdriver Notification Channels for dataflow alarm for freshness (required if alerting is on)"
  type        = list(string)
  default     = []
}

variable "scheduler_jobs" {
  description = "Taskhawk jobs to be run on scheduler (name should contain just a-z and hyphens)"
  type = list(object({
    name           = string                      # Rule name (must be unique across all jobs)
    description    = optional(string)            # Description of the job
    schedule       = string                      # Cloud Scheduler cron schedule expression
    priority       = optional(string, "default") # Which queue to scheduled task into?
    format_version = optional(string, "v1.0")    # Taskhawk message format version
    timezone       = string                      # Timezone for the schedule
    headers        = optional(map(string), {})   # Custom headers
    task           = string                      # Name of the task
    args           = optional(list(string), [])  # Task args
    kwargs         = optional(map(string), {})   # Task kwargs
    kwargs_encoded = optional(string)            # Task kwargs encoded as a JSON string (use this to get around terraform type problems), if set this is preferred over kwargs
  }))
  default  = []
  nullable = false
}

variable "scheduler_region" {
  description = "The region to use for Cloud Scheduler. This may be required if it's not set at the provider level."
  default     = ""
}

variable "enable_exactly_once_delivery" {
  description = "Enable exactly-once delivery for the PubSub subscriptions"
  default     = false
}

variable "ack_deadline_seconds" {
  description = "The ack deadline in seconds for the PubSub subscriptions"
  default     = 20
}
