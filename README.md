Taskhawk Queue App Terraform module
===================================

[Taskhawk](https://github.com/cloudchacho/taskhawk) is a replacement for celery that works on AWS SQS/SNS and
Google Pub/Sub, while keeping things pretty simple and straight forward. 

This module provides a custom [Terraform](https://www.terraform.io/) module for deploying Taskhawk 
infrastructure for Taskhawk Queue based app.

Usage
-----
```hcl
module "taskhawk-dev-myapp" {
  source   = "cloudchacho/taskhawk-queue/google"
  queue    = "dev-myapp"

  enable_alerts = true

  labels = {
    app     = "myapp"
    env     = "dev"
  }
}
```

If using a single Google project for multiple environments (e.g. dev/staging/prod), ensure that `queue` includes
your environment name.

Naming convention - lowercase alphanumeric and dashes only.

Please note Google's restrictions (if not followed, errors may be confusing and often totally wrong):
- [Labels](https://cloud.google.com/pubsub/docs/labels#requirements)
- [Resource names](https://cloud.google.com/pubsub/docs/admin#resource_names)

The Google topic and subscription names will be prefixed by `taskhawk-`.

## Caveats

### IAM

If you're using Terraform to create the Dataflow output GCS bucket, then ensure that permissions for the bucket
include `Storage Legacy Object Owner` or `Storage Object Admin`. This is done by default if using
Google Console, but not for Terraform. This can be done in Terraform like so:

```hcl
data google_project current {}

resource "google_storage_bucket_iam_member" "taskhawk_firehose_editor_iam" {
  bucket = "${google_storage_bucket.taskhawk_firehose.name}"
  role   = "roles/storage.admin"
  member = "projectEditor:${data.google_project.current.id}"
}

resource "google_storage_bucket_iam_member" "taskhawk_firehose_owner_iam" {
  bucket = "${google_storage_bucket.taskhawk_firehose.name}"
  role   = "roles/storage.admin"
  member = "projectOwner:${data.google_project.current.id}"
}
```

Alternatively, you can restrict these permissions to the user Dataflow uses, which is: `{project number}-compute@developer.gserviceaccount.com`.

The Pub/Sub topic name will be prefixed by `taskhawk-`.

## Release Notes

[Github Releases](https://github.com/cloudchacho/terraform-google-taskhawk-queue/releases)

## How to publish

Go to [Terraform Registry](https://registry.terraform.io/modules/cloudchacho/taskhawk-queue/google), and Resync module.
