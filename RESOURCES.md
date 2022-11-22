
This solution creates a VPC, which is divided into 4 subnets which are controlled with a security group on the VPC. It creates a compute instance attached to one of the public subnets. To support the storage needs of the fictional application, it has an S3 bucket with folders (and relevant lifecycles) for Images and Logs.

Since this is my first time using terraform, I relied on its documentation:
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/

Additionally, I needed the AMI for RHEL, so I tried this https://access.redhat.com/articles/3692431, and used redhat's website to find the AMI for rhel for us-west-2
