# Set up watsonx administrators for a PoC account

This non-modular terraform code will create activity tracker instances and an access group for use by PoC administrators. The PoC administrator has full account access through IAM to allow for inviting users to the account. Full control for resource groups and the services necessary for watsonx.ai along with Schematics is also added to the access group. This *should* allow members added to the group (using a list variable) to be able to create watsonx.ai team instances using the code in [../watsonxai-env-setup](../watsonxai-env-setup/).
