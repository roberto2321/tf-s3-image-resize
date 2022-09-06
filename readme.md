Pre-Requisites
-----------------

[A] Install AWS CLI and configure a profile, which we will use for Terraform credential
    - Refer this document - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

[B] Terraform installed 
    - Download Terraform - https://www.terraform.io/downloads.html


Method
-------
1. Fill the provider.tf (After configuring the AWS profile) 
2. Fill the terraform.tfvars file 
"pip_package"
	- Depending on the region you selected get the value for "pip-package" in https://github.com/keithrozario/Klayers/tree/master/deployments/python3.8/
	  Get the value for package "pillow"
3. terraform init
4. terraform apply -auto-approve 

After Resource Creation
-----------------------
Create Empty folders in S3
	1. Images
	2. Processed_Images

Now you can upload images to "Images/" folder 

This will trigger the lambda function and process the image and put back in Processed_Images

To Delete the Resources
-------------------------
terraform destroy -auto-approve