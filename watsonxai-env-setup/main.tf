# Random project suffix
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  wo_name  = "watsonx-wo-${random_string.suffix.result}"
  ml_name  = "watsonx-ml-${random_string.suffix.result}"
  ws_name  = "watsonx-ws-${random_string.suffix.result}"
  db2_name = "watsonx-db2-${random_string.suffix.result}"
  cos_name = "watsonx-cos-${random_string.suffix.result}"
}


locals {
  project_name = "${var.project_name}-${random_string.suffix.result}"
}

resource "ibm_resource_group" "resource_group" {
  name = local.project_name
}

# Watson Machine Learning Instance
resource "ibm_resource_instance" "ml-inst" {
  count = var.install_ml ? 1 : 0

  name              = local.ml_name
  service           = "pm-20"
  plan              = var.ml_plan
  location          = var.region
  resource_group_id = ibm_resource_group.resource_group.id
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Watson Studio Instance
resource "ibm_resource_instance" "ws-inst" {
  count = var.install_ws ? 1 : 0

  name              = local.ws_name
  service           = "data-science-experience"
  plan              = var.ws_plan
  location          = var.region
  resource_group_id = ibm_resource_group.resource_group.id

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# COS Instance
resource "ibm_resource_instance" "cos-inst" {
  count = var.install_cos ? 1 : 0

  name              = local.cos_name
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = "global"
  resource_group_id = ibm_resource_group.resource_group.id

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# OpenScale Instance - OPTIONAL
resource "ibm_resource_instance" "os-inst" {
  count = var.install_os ? 1 : 0

  name              = local.wo_name
  service           = "aiopenscale"
  plan              = var.wo_plan
  location          = var.region
  resource_group_id = ibm_resource_group.resource_group.id
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}


# DB2 Instance - OPTIONAL
resource "ibm_resource_instance" "db2-inst" {
  count = var.install_db2 ? 1 : 0

  name              = local.db2_name
  service           = "dashdb-for-transactions"
  location          = var.region
  resource_group_id = ibm_resource_group.resource_group.id
  plan              = var.db2_plan

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

# access group for full watsonx.ai service control - including create projects
resource "ibm_iam_access_group" "accgrp" {
  name = local.project_name
  description = "Full user access to environment: ${local.project_name}"
}

resource "ibm_iam_access_group_policy" "rg_policy" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Viewer"]
  resources {
    resource_type = "resource-group"
    resource      = ibm_resource_group.resource_group.id
  }
}

resource "ibm_iam_access_group_policy" "ml_policy" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Manager", "Editor"]
  resources {
    service              = "pm-20"
    resource_instance_id = element(split(":", ibm_resource_instance.ml-inst[0].id), 7)
  }
}

resource "ibm_iam_access_group_policy" "os_policy" {
  count = var.install_os ? 1 : 0

  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Writer", "Editor"]
  resources {
    service              = "aiopenscale"
    resource_instance_id = element(split(":", ibm_resource_instance.os-inst[0].id), 7)
  }
}

resource "ibm_iam_access_group_policy" "ws_policy" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Operator", "Editor"]
  resources {
    service              = "data-science-experience"
    resource_instance_id = element(split(":", ibm_resource_instance.ws-inst[0].id), 7)
  }
}

resource "ibm_iam_access_group_policy" "cos_policy" {
  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Manager", "Viewer", "Administrator"]

  resources {
    service              = "cloud-object-storage"
    resource_instance_id = element(split(":", ibm_resource_instance.cos-inst[0].id), 7)
  }
}

resource "ibm_iam_access_group_policy" "db2_policy" {
  count = var.install_db2 ? 1 : 0

  access_group_id = ibm_iam_access_group.accgrp.id
  roles           = ["Operator", "Editor"]
  resources {
    service              = "dashdb-for-transactions"
    resource_instance_id = element(split(":", ibm_resource_instance.db2-inst[0].id), 7)
  }
}

# access group for minimal watsonx.ai use, scoped to RG, must be invited to project
resource "ibm_iam_access_group" "min-accgrp" {
  name = "${local.project_name}-minimal"
  description = "Minimum user access to environment: ${local.project_name}"
}

resource "ibm_iam_access_group_policy" "rg_policy_min" {
  access_group_id = ibm_iam_access_group.min-accgrp.id
  roles           = ["Viewer"]
  resources {
    resource_type = "resource-group"
    resource      = ibm_resource_group.resource_group.id
  }
}

resource "ibm_iam_access_group_policy" "ml_policy_min" {
  access_group_id = ibm_iam_access_group.min-accgrp.id
  roles           = ["Viewer"]
  resources {
    service              = "pm-20"
    resource_instance_id = element(split(":", ibm_resource_instance.ml-inst[0].id), 7)
  }
}

resource "ibm_iam_access_group_policy" "ws_policy_min" {
  access_group_id = ibm_iam_access_group.min-accgrp.id
  roles           = ["Viewer"]
  resources {
    service              = "data-science-experience"
    resource_instance_id = element(split(":", ibm_resource_instance.ws-inst[0].id), 7)
  }
}

resource "ibm_iam_access_group_policy" "cos_policy_min" {
  access_group_id = ibm_iam_access_group.min-accgrp.id
  roles           = ["Reader", "Viewer" ]

  resources {
    service              = "cloud-object-storage"
    resource_instance_id = element(split(":", ibm_resource_instance.cos-inst[0].id), 7)
  }
}
