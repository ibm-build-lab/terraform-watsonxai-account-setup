# Terraform scripts for watsonx.ai PoC account setup

This repo contains a small collection of terraform code for IBM Cloud to assist in setting up environments for watsonx in an IBM Cloud account. The terraform code has been tested for both local execution and execution from Schematics.

* [watsonxai-env-setup](watsonxai-env-setup) Create services and access group for a watsonx.ai team instance. The code uses a random suffix to the project so that it can be run multiple times in the account, potentially creating different watsonx.ai environments, in different RGs for different squads using the PoC environment. Note that there is only one OpenScale instance allowed in an account so if that is needed for a team project and enabled, that is the only team project that can use the instance.
* [admin-setup](admin-setup) Create a baseline IBMer administrator access for the account that will allow visibility and control for all of the watsonx.ai services as well as the ability to add and modify further IAM Access Groups/Policies for the account. Also adds services to the account for AT for auditing activity in the account.
