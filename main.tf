#####################################################################
######     Enable the Cloud Billing API Service
#####################################################################
resource "google_project_service" "enable_cloudbilling_api" {
  project = var.project_id
  service = "cloudbilling.googleapis.com"
}

#####################################################################
######     Enable the Billing Budgets API Service 
#####################################################################

resource "google_project_service" "enable_billing_budgets_api" {
  project = var.project_id
  service = "billingbudgets.googleapis.com"
}

#####################################################################
######     Enable the Cloud Functions API Service
#####################################################################

resource "google_project_service" "enable_cloud_functions_api" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"
}

#####################################################################
######     Enable the Cloud Build API Service
#####################################################################

resource "google_project_service" "enable_cloud_build_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

#####################################################################
######     Enable the Cloud Pub/Sub API Service
#####################################################################

resource "google_project_service" "enable_cloud_pubsub_api" {
  project = var.project_id
  service = "pubsub.googleapis.com"
}


# #####################################################################
# ######     Create Cloud Storage bucket for function code
# #####################################################################

# resource "google_storage_bucket" "budget_alerts_code_bucket" {
#   name               = "${var.project_id}-budget_alerts_code_bucket"
#   project            = var.project_id
#   location           = var.region

#   versioning {
#     enabled = true
#   }
# }

############################################################################
#####      Create archive for Function
############################################################################

# resource "google_storage_bucket_object" "archive" {
#   name   = "main.zip"
#   bucket = "${var.project_id}-budget_alerts_code_bucket"
#   source = "main.zip"
# }
# resource "google_storage_bucket_object" "archive" {
#   name   = "archive.zip"
#   bucket =  "${var.project_id}-budget_alerts_code_bucket"
#   source = "./python_files"
# }

#############################################################################
######  Creates archive file by zipping main.py and requirements.txt
#############################################################################
data "archive_file" "archive_zip" {
  type        = "zip"
  source_dir  = "./python_files"
  output_path = "./archive.zip"
}

resource "google_storage_bucket_object" "archive_zip" {
  name   = "archive.zip"
  bucket = "${var.project_id}-budget_alerts_code_bucket"
  source = data.archive_file.archive_zip.output_path
}


# data "archive_file" "hello_zip" {
#   type        = "zip"
#   source_dir  = "./python_files"
#   output_path = "archive.zip"
# }

# data "archive_file" "zipfile" {
#   type        = "zip"
#   output_path = "${var.project_id}-budget_alerts_code_bucket/archive.zip"
   
#   source {
#     content = "./python_file/main.py"
#     filename = "main.py"
#   }

#   source {
#     content = "./python_file/requirements.txt"
#     filename = "requirements.txt"
#   }
# }
# ############################################################################
# #####      Create archive for Function
# ############################################################################

# resource "google_storage_bucket_object" "archive" {
#   name   = "archive.zip"
#   bucket = "${var.project_id}-budget_alerts_code_bucket"
#   source = "archive.zip"
# }
# #########################################################################################
# ######   Build the Pub/Sub Budget Notification Topic
# #########################################################################################

resource "google_pubsub_topic" "pubsub_budget_alerts_topic" {
  name    = "budget-alerts-topic"
  project = var.project_id
}

# #########################################################################################
# ######   Get the Billing Account for the Project
# #########################################################################################

# data "google_billing_account" "acct" {
#   display_name = "billing_account"
#   open         = true
# }

# resource "google_project" "my_project" {
#   name       = var.project_id
#   project_id = var.project_id
#   org_id     = var.org_id

#   billing_account = data.google_billing_account.acct.id
# }

# resource "google_service_account_iam_binding" "token-creator-iam" {
#     service_account_id = "projects/ttec-335312/serviceAccounts/ttec-serice-account5@ttec-335312.iam.gserviceaccount.com"
#     role               = "roles/iam.serviceAccountTokenCreator"
#     members = [
#         "bill@cloudbakers.com",
#     ]
# }
# #########################################################################################
# ######   Set up Billing Budget and link to Pub/Sub topic
# #########################################################################################

# data "google_billing_account" "account" {
#   billing_account = "01E19A-4A22BB-4C0875"
# }


# resource "google_billing_budget" "project_budget_alert" {
#   #provider        = google-beta
#   billing_account = data.google_billing_account.account.id
#   #billing_account = var.billing_account
#   display_name    = "Budget Alert"

#   budget_filter {
#     projects = ["projects/${var.project_id}", ]
#   }

#   amount {
#     specified_amount {
#       currency_code = "USD"
#       units         = var.budget_amount
#     }
#   }

#   all_updates_rule {
#     pubsub_topic = "projects/${var.project_id}/topics/${var.budget_pubsub_topic}"
#   }

#   dynamic "threshold_rules" {
#     for_each = toset([0.7, 0.8, 0.9, 1.0, 1.25, 1.5])
#     content {
#       threshold_percent = threshold_rules.value
#     }
#   }
#}
# resource "google_pubsub_topic" "pubsub_budget_alerts_topic" {
#   name    = "budget-alerts-topic"
#   project = var.project_id
# }



data "google_billing_account" "account" {
  billing_account = "01E19A-4A22BB-4C0875"
}

resource "google_billing_budget" "budget" {
  billing_account = data.google_billing_account.account.id
  display_name = "Example Billing Budget"


  budget_filter {
    projects = ["projects/${var.project_id}", ]
  }

  amount {
  specified_amount {
    currency_code = "USD"
    units         = var.budget_amount
    }
  }

   all_updates_rule {
    pubsub_topic = "projects/${var.project_id}/topics/${var.budget_pubsub_topic}"
    monitoring_notification_channels = [
      google_monitoring_notification_channel.notification_channel.id,
    ]
    disable_default_iam_recipients = false
  }

   dynamic "threshold_rules" {
    for_each = toset([0.7, 0.8, 0.9, 1.0, 1.25, 1.5])
    content {
      threshold_percent = threshold_rules.value
    }
  }
}

resource "google_monitoring_notification_channel" "notification_channel" {
  project = var.project_id
  display_name = "Example Notification Channel"
  type         = "email"

  labels = {
    email_address = "bill@cloudbakers.com"
  }
}






# data "google_billing_account" "account" {
#     billing_account = "01E19A-4A22BB-4C0875"
#  }


# data "google_project" "project" {
#   project_id = var.project_id
# }

# output "project_number" {
#   value = data.google_project.project.number
# }

# resource "google_billing_budget" "budget" {
#   billing_account = data.google_billing_account.account.id
#   display_name = "Sample budget"

#   budget_filter {
#     projects = ["projects/${data.google_project.project.number}"]  #ensure budget for this project only
#   }

#   amount {
#     specified_amount {
#       currency_code = "USD"
#       units         = "100"
#     }
#   }

#   threshold_rules {
#     threshold_percent = 0.8
#   }
#   threshold_rules {
#     threshold_percent = 1.0
#     spend_basis       = "FORECASTED_SPEND"
#   }

#   all_updates_rule {
#     pubsub_topic = "projects/project/topics/budget_notification_topic"
#   }
# }



####Create feed for the pubsub topics
# resource "google_cloud_asset_project_feed" "project_feed" {
#   project          = var.project_id
#   feed_id          = "remove_container"
#   content_type     = "RESOURCE"

#   asset_types = [
#     "containerregistry.googleapis.com/Image",
#   ]

#    feed_output_config {
#      pubsub_destination {
#        topic = google_pubsub_topic.topic.id
#      }
#    }

#     condition {
#     expression = <<-EOT
#     !temporal_asset.deleted &&
#     temporal_asset.prior_asset_state == google.cloud.asset.v1.TemporalAsset.PriorAssetState.DOES_NOT_EXIST
#     EOT
#     title = "created"
#     description = "Send notifications on creation events"
#   }

# #########################################################################################
# ######   Build the Pub/Sub Result Topic
# ##########################################################################################

# resource "google_pubsub_topic" "result_topic" {
#   name = "result_topic"
#   project = var.project_id
# }

# ##########################################################################################
# ######      Create the Cloud Function to stop all of instances in offending project
# ##########################################################################################

resource "google_cloudfunctions_function" "stop_instances_on_budget_violation" {
  name        = "budget_violation"
  description = "stop instances where budget violation"
  runtime     = "python39"
  region      = "us-central1"
  project     = var.project_id

  available_memory_mb   = 128
  source_archive_bucket = "${var.project_id}-budget_alerts_code_bucket"
  source_archive_object = "archive.zip"
  timeout               = 60
  entry_point           = "limit_use"

  environment_variables = {
    GCP_PROJECT="${var.project_id}",
    ZONE= "us-central1-c",
  }

   event_trigger {
       event_type= "google.pubsub.topic.publish"
       resource= "budget-alerts-topic"
}

  # event_trigger {
  #   event_type = "google.storage.object.finalize"
  #   resource = "${var.project_id}-image-input"
  # }
}

# #########################################################################################
# #######    Build and deploy the text translation Google Cloud function
# #######    with a Cloud Pub/Sub trigger, 
# #########################################################################################

# resource "google_cloudfunctions_function" "translate_text" {
#   name        = "translate_text"
#   description = "translate text from uploaded file"
#   runtime     = "python39"
#   region      = "us-central1"
#   project     = var.project_id
  
#   available_memory_mb   = 128
#   source_archive_bucket = "terraform1hwp"
#   source_archive_object = "function-source.zip"
#   timeout               = 60
#   entry_point           = "translate_text"

#    environment_variables = {
#     GCP_PROJECT="${var.project_id}",
#     RESULT_TOPIC="result_topic"
#   }

#   event_trigger {
#     event_type = "google.pubsub.topic.publish"
#     resource = "translate_topic"
#   }
# }

# ##########################################################################################
# #####  Build and Deploy Google Cloud Function to save results to Cloud Storage
# ##########################################################################################

# resource "google_cloudfunctions_function" "save_result" {
#   name        = "save_result"
#   description = "save results to Cloud Storage"
#   runtime     = "python39"
#   region      = "us-central1"
#   project     = var.project_id

#   available_memory_mb   = 128
#   source_archive_bucket = "terraform1hwp"
#   source_archive_object = "function-source.zip"
#   timeout               = 60
#   entry_point           = "save_result"
  
#   environment_variables = {
#     GCP_PROJECT="${var.project_id}",
#     RESULT_BUCKET="${var.project_id}-image-output"
#   }
#   event_trigger {
#       event_type= "google.pubsub.topic.publish"
#       resource= "result_topic"
#    }
# }