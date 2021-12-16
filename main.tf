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
# ######     Create Cloud Storage bucket for image input
# #####################################################################

# resource "google_storage_bucket" "image_input_bucket" {
#     project = var.project_id
#     name     = "${var.project_id}-image-input"
#     location = var.region
# }

# #####################################################################
# ######     Create Cloud Storage bucket for Translation/OCR output
# #####################################################################

# resource "google_storage_bucket" "image_output_bucket" {
#     project = var.project_id
#     name     = "${var.project_id}-image-output"
#     location = var.region
# }

# #########################################################################################
# ######   Build the Pub/Sub Translate Topic
# ##########################################################################################

# resource "google_pubsub_topic" "translate_topic" {
#   name = "translate_topic"
#   project = var.project_id
# }

# #########################################################################################
# ######   Build the Pub/Sub Result Topic
# ##########################################################################################

# resource "google_pubsub_topic" "result_topic" {
#   name = "result_topic"
#   project = var.project_id
# }

# ##########################################################################################
# ######      Build and depoly Google Cloud Function for OCR extraction upon input 
# ######      file upload to input bucket
# ##########################################################################################

# resource "google_cloudfunctions_function" "process_image" {
#   name        = "process_image"
#   description = "process image from uploaded file"
#   runtime     = "python39"
#   region      = "us-central1"
#   project     = var.project_id

#   available_memory_mb   = 128
#   source_archive_bucket = "terraform1hwp"
#   source_archive_object = "function-source.zip"
#   timeout               = 60
#   entry_point           = "process_image"

#   environment_variables = {
#     GCP_PROJECT="${var.project_id}",
#     TRANSLATE_TOPIC="translate_topic",
#     RESULT_TOPIC="result_topic",
#     TO_LANG="es,en,fr,ja",
#   }

#   event_trigger {
#     event_type = "google.storage.object.finalize"
#     resource = "${var.project_id}-image-input"
#   }
# }

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