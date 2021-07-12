locals {
  priority_empty   = ""
  priority_default = "default"
  priority_low     = "low"
  priority_high    = "high"
  priority_bulk    = "bulk"

  scheduler_jobs = var.scheduler_jobs == null ? [] : var.scheduler_jobs
}
