

data "ibm_resource_group" "resourceGroupDefault" {
  is_default = "true"
}

## Create Activity instances in default resource group
resource "ibm_resource_instance" "at_instance1" {
  name              = "logging-instance-eu-de"
  service           = "logdnaat"
  plan              = var.at_plan
  location          = "eu-de"
  resource_group_id = data.ibm_resource_group.resourceGroupDefault.id
}

resource "ibm_resource_instance" "at_instance2" {
  name              = "logging-instance-us-south"
  service           = "logdnaat"
  plan              = var.at_plan
  location          = "us-south"
  resource_group_id = data.ibm_resource_group.resourceGroupDefault.id
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
  roles           = ["Operator", "Editor"]
  resources {
    service = "logdnaat"
  }
}

// Administer: All resource group
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

resource "ibm_iam_user_invite" "invite_user" {
  count = length(var.acct_mgr_admins_user_ids[0]) > 3 ? 1 : 0

  users         = var.acct_mgr_admins_user_ids
  access_groups = [ibm_iam_access_group.acct_mgr_admins_access_group.id]
}

# resource "ibm_iam_access_group_members" "acct_mgr_admins_members" {
#   access_group_id = ibm_iam_access_group.acct_mgr_admins_access_group.id
#   ibm_ids         = var.acct_mgr_admins_user_ids
# }
