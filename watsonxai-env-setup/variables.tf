variable "project_name" {
  type    = string
  default = "watsonxai"
}

variable "install_db2" {
  type        = bool
  description = "Install DB2 instance"
  default     = false
}

variable "install_cos" {
  type        = bool
  description = "Add COS instance"
  default     = true
}

variable "install_ml" {
  type        = bool
  description = "Install Machine Learning"
  default     = true
}

variable "install_os" {
  type        = bool
  description = "Install OpenScale"
  default     = false
}

variable "install_ws" {
  type        = bool
  description = "Install Watson Studio"
  default     = true
}

variable "ws_instance" {
  type    = string
  default = "Watson Studio"
}

variable "ml_instance" {
  type    = string
  default = "Watson Machine Learning"
}

variable "os_instance" {
  type    = string
  default = "Watson OpenScale"
}

variable "cos_instance" {
  type    = string
  default = "Cloud Object Storage"
}

variable "db2_instance" {
  type    = string
  default = "Db2"
}

variable "ws_plan" {
  type    = string
  default = "professional-v1"
}

variable "wo_plan" {
  type    = string
  default = "lite"
}

variable "ml_plan" {
  type    = string
  default = "v2-standard"
}

variable "cos_plan" {
  type    = string
  default = "standard"
}

variable "db2_plan" {
  type    = string
  default = "standard"
}

variable "region" {
  description = "Region"
  type        = string
  default     = "us-south"
}