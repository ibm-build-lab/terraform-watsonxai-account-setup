variable "logs_retention" {
  type        = string
  description = "Retention period in days to use, one of 7, 14, 30, 90 ."
  default     = "7"
}

variable "cl_plan" {
  type        = string
  description = "Cloud Logs plan to use for AT data."
  default     = "standard"
}

variable "cos_plan" {
  type        = string
  description = "COS plan to use for Cloud Logs buckets."
  default     = "standard"
}

variable "acct_mgr_admins_access_group_name" {
  type        = string
  description = "Name for the watsonx Admin access group for the account"
  default     = "WATSONX-MGR-ADMIN"
}

variable "acct_mgr_admins_user_ids" {
  type        = list(string)
  description = "Names of the users to add to the watsonx Admin access group - do not include account owner IBMid"
  default     = [""]
}