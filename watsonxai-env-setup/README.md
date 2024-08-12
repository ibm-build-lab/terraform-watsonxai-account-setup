# Configure a watsonx.ai environment

This non-modular terraform code will create a new resource group and the specified services for experimentation for watsonx.ai. A random character suffix is appended to the resource group name and all of the services. Additionally, an access group with the same suffix is added. Users are not added as part of the code, but can be invited to the account as needed, specifying the created access group.
