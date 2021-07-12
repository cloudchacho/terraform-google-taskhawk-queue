locals {
  title_suffix           = var.alerting_project != data.google_project.current.project_id ? format(" (%s)", data.google_project.current.name) : ""
  filter_suffix          = var.alerting_project != data.google_project.current.project_id ? format(" project=\"%s\"", data.google_project.current.project_id) : ""
  dataflow_filter_suffix = var.alerting_project != data.google_project.current.project_id ? format(" resource.label.\"project_id\"=\"%s\"", data.google_project.current.project_id) : ""

  iam_service_accounts = var.iam_service_accounts == null ? [] : var.iam_service_accounts
}
