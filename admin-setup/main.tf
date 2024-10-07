data "ibm_resource_group" "resourceGroupDefault" {
  is_default = "true"
}

# Random string to append to bucket names to avoid collisions with old buckets in reclamations for repeat cycles
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

## Create COS instance in default resource group and buckets for Cloud Logs
resource "ibm_resource_instance" "cos_instance" {
  name              = "cos-cloud-logs"
  resource_group_id = data.ibm_resource_group.resourceGroupDefault.id
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = "global"

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

resource "ibm_cos_bucket" "cl-data-smart-us-south-rand" {
  bucket_name          = "cloud-logs-data-us-south-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = "us-south"
  storage_class        = "standard"
}

resource "ibm_cos_bucket" "cl-metrics-smart-us-south-rand" {
  bucket_name          = "cloud-logs-metrics-us-south-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = "us-south"
  storage_class        = "standard"
}

## Create Cloud Log instances in default resource group
resource "ibm_resource_instance" "cloud_logs_instance" {
  name              = "cloud-logs-instance"
  service           = "logs"
  plan              = var.cl_plan
  location          = "us-south"
  resource_group_id = data.ibm_resource_group.resourceGroupDefault.id
  parameters = {
    retention_period        = var.logs_retention
    logs_bucket_crn         = ibm_cos_bucket.cl-data-smart-us-south-rand.crn
    logs_bucket_endpoint    = ibm_cos_bucket.cl-data-smart-us-south-rand.s3_endpoint_public
    metrics_bucket_crn      = ibm_cos_bucket.cl-metrics-smart-us-south-rand.crn
    metrics_bucket_endpoint = ibm_cos_bucket.cl-metrics-smart-us-south-rand.s3_endpoint_public
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
  depends_on = [
    ibm_iam_authorization_policy.logs-to-cos-policy
  ]
}

# Add permission from logs service instance to cos service instance
resource "ibm_iam_authorization_policy" "logs-to-cos-policy" {
  source_service_name         = "logs"
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = ibm_resource_instance.cos_instance.guid
  roles                       = ["Writer"]
}

# Add ATracker target
resource "ibm_atracker_target" "atracker_cloudlogs_target" {
  cloudlogs_endpoint {
    target_crn = ibm_resource_instance.cloud_logs_instance.crn
  }
  name = "cloudlogs-target"
  target_type = "cloud_logs"
  region = "us-south"
}

resource "ibm_atracker_settings" "atracker_settings" {
  default_targets = [ ibm_atracker_target.atracker_cloudlogs_target.id ]
  metadata_region_primary = "us-south"
  permitted_target_regions = ["us-south"]
  private_api_endpoint_only = false
  # Optional but recommended lifecycle flag to ensure target delete order is correct
  lifecycle {
    create_before_destroy = true
  }
}

resource "ibm_atracker_route" "atracker_route" {
  name = "atracker-single-route"
  rules {
    target_ids = [ ibm_atracker_target.atracker_cloudlogs_target.id ]
    locations = [ "us-south", "global" ]
  }
  lifecycle {
    # Recommended to ensure that if a target ID is removed here and destroyed in a plan, this is updated first
    create_before_destroy = true
  }
}

# Add permission from atracker service instance to logs service instance
resource "ibm_iam_authorization_policy" "atracker_policy" {
  source_service_name         = "atracker"
  target_service_name         = "logs"
  target_resource_instance_id = ibm_resource_instance.cloud_logs_instance.guid
  roles                       = ["Sender"]
}



## Create access group for watsonx administrators
resource "ibm_iam_access_group" "acct_mgr_admins_access_group" {
  name        = var.acct_mgr_admins_access_group_name
  description = "Administrators for watsonx instances"
}

## Add account administration policies

// Administer: All account management services
resource "ibm_iam_access_group_policy" "admins_acct_mgmt_policy" {
  access_group_id    = ibm_iam_access_group.acct_mgr_admins_access_group.id
  roles              = ["Administrator"]
  account_management = true
}

## Add service and resource administration policies

// Administer and manage: All service in all resource groups
# resource "ibm_iam_access_group_policy" "admins_all_services_policy" {
#   access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
#   roles =  ["Administrator", "Manager"]
#   resources  {
#     resource_group_id = "*"
#   }
# }

resource "ibm_iam_access_group_policy" "schematics_policy" {
  access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
  roles           = ["Manager", "Administrator"]
  resources {
    service = "schematics"
  }
}

resource "ibm_iam_access_group_policy" "cos_policy" {
  access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
  roles           = ["Manager", "Administrator"]
  resources {
    service = "cloud-object-storage"
  }
}

resource "ibm_iam_access_group_policy" "ws_policy" {
  access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
  roles           = ["Administrator"]
  resources {
    service = "data-science-experience"
  }
}

resource "ibm_iam_access_group_policy" "ml_policy" {
  access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
  roles           = ["Manager", "Administrator"]
  resources {
    service = "pm-20"
  }
}

resource "ibm_iam_access_group_policy" "db2_policy" {
  access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
  roles           = ["Manager", "Administrator"]
  resources {
    service = "dashdb-for-transactions"
  }
}

resource "ibm_iam_access_group_policy" "os_policy" {
  access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
  roles           = ["Writer", "Administrator"]
  resources {
    service = "aiopenscale"
  }
}

resource "ibm_iam_access_group_policy" "at_policy" {
  access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
  roles           = ["Manager", "Operator", "Editor"]
  resources {
    service = "logs"
  }
}

# // Administer: All resource group
resource "ibm_iam_access_group_policy" "admins_all_resource_groups_policy" {
  access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
  roles           = ["Administrator"]
  resources {
    resource_type = "resource-group"
  }
}

/*
 * Invite to the account watsonx environment admins (IBMers)
 */

# resource "ibm_iam_user_invite" "invite_user" {
#   count = var.invite_admins ? 1 : 0

#   users         = var.acct_mgr_admins_user_ids
#   access_groups = [ibm_iam_access_group.acct_mgr_admins_access_group.id]
# }

removed {
  from = ibm_iam_user_invite.invite_user

  lifecycle {
    destroy = false
  }
}

resource "ibm_iam_access_group_members" "acct_mgr_admins_members" {
  access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
  ibm_ids         = var.acct_mgr_admins_user_ids
}
