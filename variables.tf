variable "project_id" {
    description = "Name of the project for resource creation."
    type = string
    default = "cloud-functions-course-324509"
}

variable "region" {
    description = "Name of the region for resource creation."
    type = string
    default = "us-central1"
}

variable "zone" {
    description = "Name of the region for resource creation."
    type = string
    default = "us-central1-c"
}

variable "billing_account"{
    description = "Billing accont for the project"
    type = string
    default = "01E19A-4A22BB-4C0875"
}

variable "budget_amount"{
    description = "Budget for the project"
    type = string
    default = "100"
}

variable "org_id"{
    description = "Organization ID for the project"
    type = string
    default = "305658411957" 
}

variable "budget_pubsub_topic"{
    description = "Pubsub topic"
    type = string
    default = "budget-alerts-topic"

}