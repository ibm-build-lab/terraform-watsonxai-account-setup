variable "at_plan" {
  type        = string
  description = "Activity tracker plan to use for AT instances."
  default     = "30-day"
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