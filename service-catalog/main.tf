# ==========
# Provisions an AWS Service Catalog Product (specifically, the EC2 Apache Webserver from the Getting Started Library, which should be added to your portfolio)
# ==========

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.28.0"
    }
    tls = {}
  }
}

provider "tls" {}
provider "aws" {
  region = var.aws-region
}

# ==========
# KeyPair
# ==========

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "adhoc" {
  key_name   = "adhoc"
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./adhoc.pem"
  }
}

# ==========
# Provision an EC2 Instance from the AWS Service Catalog
# ==========

data "aws_servicecatalog_launch_paths" "ec2_instance" {
  product_id = "<prod-etc...>" # TODO: REPLACE THIS VALUE WITH THE ID OF THE PRODUCT IN THE CATALOG
}

resource "aws_servicecatalog_provisioned_product" "provisioned_ec2_instance" {
  name                     = "ec2Instance"
  product_id               = data.aws_servicecatalog_launch_paths.ec2_instance.product_id
  path_id                  = data.aws_servicecatalog_launch_paths.ec2_instance.summaries[0].path_id
  provisioning_artifact_id = "<pa-etc...>" # TODO: REPLACE THIS VALUE WITH THE ID FOR THE VERSION OF THE PRODUCT IN THE CATALOG

  provisioning_parameters {
    key   = "KeyPair"
    value = aws_key_pair.adhoc.key_name # EITHER USE THIS AS DEFINED AND PROVISIONED ABOVE, OR ENTER THE NAME OF AN EXISTING KEYPAIR (POSSIBLY AS A VAR)
  }

  provisioning_parameters {
    key   = "VPC"
    value = var.default-vpc
  }

  provisioning_parameters {
    key   = "RemoteAccessCIDR"
    value = "0.0.0.0/0" # EITHER USE THIS AS DEFINED, OR CHANGE THIS TO BE A SPECIFIC IP/RANGE
  }

  provisioning_parameters {
    key   = "InstanceType"
    value = "t3.medium" # EITHER USE THIS AS DEFINED, REMOVE IT TO ACCEPT THE DEFAULT, OR ENTER A VALID INSTANCE TYPE
  }
}