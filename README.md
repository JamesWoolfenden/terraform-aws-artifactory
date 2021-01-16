# terraform-aws-artifactory

[![Build Status](https://github.com/JamesWoolfenden/terraform-aws-artifactory/workflows/Verify%20and%20Bump/badge.svg?branch=master)](https://github.com/JamesWoolfenden/terraform-aws-artifactory)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-aws-artifactory.svg)](https://github.com/JamesWoolfenden/terraform-aws-artifactory/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-aws-artifactory.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-aws-artifactory/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.14.0-blue.svg)
[![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/JamesWoolfenden/terraform-aws-artifactory/cis_aws)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=JamesWoolfenden%2Fterraform-aws-artifactory&benchmark=CIS+AWS+V1.2)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![checkov](https://img.shields.io/badge/checkov-verified-brightgreen)](https://www.checkov.io/)
[![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/jameswoolfenden/terraform-aws-artifactory/general)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=JamesWoolfenden%2Fterraform-aws-artifactory&benchmark=INFRASTRUCTURE+SECURITY)

Updated and significantly modified from <https://github.com/jfrog/JFrog-Cloud-Installers>

This method has a number of Issues including:

- SSL termination, requires upfront provision of non ACM certificate rather than termination of SSL at an ELB.
- Creates an IAM user.
- Generates access keys for IAM user and adds it to filesystem of an instance.
- Security groups very very open

## Terraform Template For Artifactory Enterprise

## Prerequisites

- An AWS account
- Basic knowledge of AWS
- Predefined Keys
- Basic knowledge of Artifactory
- Learn about [system requirements for Artifactory](https://www.jfrog.com/confluence/display/RTF/System+Requirements#SystemRequirements-RecommendedHardware)
- Learn more about Terraform AWS provider follow: https://www.terraform.io/docs/providers/aws/index.html

## Usage

There are 2 examples included one, provisions into an existing VPC the other create a vpc for you as well.

example
├── examplea
└── exampleb-newvpc

Copy either as you starting point or make your own by adding a module definition to your own code module.artifactory.tf:

![alt text](./diagram/artifactory.png)

```terraform
module "artifactory" {
  source             = "JamesWoolfenden/artifactory-oss/aws"
  version            = "0.1.0"
  common_tags        = var.common_tags
  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
  ssl_certificate_id = var.ssl_certificate_id
  vpc_cidr           = var.vpc_cidr
  ssh_access         = [module.ip.cidr]
  access_cidr        = [module.ip.cidr]
  bucket_name        = "artifactory-${data.aws_caller_identity.current.account_id}"
  instance_type      = "m4.xlarge"
  record             = var.record
  zone_id            = var.zone_id
}

```

### Steps to Deploy Artifactory Enterprise Using Terraform Template

1. Set your AWS account credentials by setting environment variables:

   ```bash
       export AWS_ACCESS_KEY_ID="your_access_key"
       export AWS_SECRET_ACCESS_KEY="your_secret_key"
       export AWS_DEFAULT_REGION="aws_region"
   ```

   To learn more about Terraform aws provider follow there documentation.
   https://www.terraform.io/docs/providers/aws/index.html

2. Modify the default values in the `variables.tf` file

3. Pass the Artifactory Enterprise licenses as a string in the variables `artifactory_license_1-5`.
   For example: Change disk space to 500Gb:

   ```bash
    variable "volume_size" {
      description = "Disk size for each EC2 instances"
      default     = 500
    }
   ```

4. Run the `terraform init -var 'key_name=myAwsKey'` command. This will install the required plugin for the AWS provider.

5. Run the `terraform plan -var 'key_name=myAwsKey'` command.

6. Run the `terraform apply -var 'key_name=myAwsKey'` command to deploy Artifactory Enterprise cluster on AWS

   **Note**: it takes approximately 15 minutes to bring up the cluster.

7. You will receive ELB Url to access Artifactory. By default, this template starts only one node in the Artifactory cluster.
   It takes 7-10 minutes for Artifactory to start and to attach the instance to the ELB.The output can be viewed as:

   ```terraform
    Outputs:

    address = artifactory-elb-265664219.us-west-2.elb.amazonaws.com
   ```

8. Access the Artifactory UI using ELB Url provided in outputs.

9. Scale your cluster using following command: `terraform apply -var 'key_name=myAwsKey' -var 'secondary_node_count=2'`
   In this example we are scaling artifactory cluster to 2 nodes.

   **Note**: You can only scale nodes to number of artifactory licenses you have available for cluster.

10. SSH into Artifactory primary instance and type [inactiveServerCleaner](inactiveServerCleaner.groovy) plugin in `'/var/opt/jfrog/artifactory/etc/plugins'` directory.
    (Optional) To destroy the cluster, run the following commend: `terraform destroy -var 'key_name=myAwsKey'`

### Note

This template only supports Artifactory version 5.8.x and above.
Turn off daily backups. Read Documentation provided [here](https://www.jfrog.com/confluence/display/RTF/Managing+Backups).

**Note**: In this template as default S3 is default filestore and data is persisted in S3. If you keep daily backups on disk space (default 250Gb) will get occupied quickly.
Use an SSL Certificate with a valid wildcard to your artifactory as docker registry with subdomain method.

### Use Artifactory as backend

To to store state as an artifact in a given repository of Artifactory, see [https://www.terraform.io/docs/backends/types/artifactory.html](https://www.terraform.io/docs/backends/types/artifactory.html)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |
| template | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_cidr | n/a | `list(any)` | n/a | yes |
| artifactory\_server\_name | Provide artifactory server name to be used in Nginx. e.g artifactory for artifactory.jfrog.team | `string` | `"artifactory"` | no |
| artifactory\_sg\_name | (optional) describe your variable | `string` | `"artifactory_sg"` | no |
| autoscaling\_group\_name | artifactory autoscaling group | `string` | `"artifactory autoscaling group"` | no |
| bucket\_name | AWS S3 Bucket name | `string` | n/a | yes |
| common\_tags | Implements the common tags scheme | `map(any)` | <pre>{<br>  "createdby": "Terraform"<br>}</pre> | no |
| db\_allocated\_storage | The size of the database (Gb) | `string` | `"5"` | no |
| db\_instance\_class | The database instance type | `string` | `"db.t2.small"` | no |
| db\_name | MySQL database name | `string` | `"artdb"` | no |
| db\_password | Database password | `string` | `"password"` | no |
| db\_user | Database user name | `string` | `"artifactory"` | no |
| elb\_name | The name of the Load balancer | `string` | `"artifactoryelb"` | no |
| extra\_java\_options | Setting Java Memory Parameters for Artifactory. Learn about system requirements for Artifactory https://www.jfrog.com/confluence/display/RTF/System+Requirements#SystemRequirements-RecommendedHardware. | `string` | `"-server -Xms2g -Xmx14g -Xss256k -XX:+UseG1GC -XX:OnOutOfMemoryError=\\\\"kill -9 %p\\\\""` | no |
| instance\_type | Artifactory EC2 instance type | `string` | n/a | yes |
| key\_name | Desired name of AWS key pair | `string` | `"jfrog"` | no |
| master\_key | Master key for Artifactory cluster. Generate master.key using command '$openssl rand -hex 16' | `string` | `"35767fa0164bac66b6cccb8880babefb"` | no |
| profile\_name | Instance profile name | `string` | `"artifactory"` | no |
| rds | Settings for the DB instance | `map(any)` | <pre>{<br>  "engine": "mysql",<br>  "engine_version": "5.5",<br>  "multi_az": "false",<br>  "skip_final_snapshot": "true",<br>  "storage_type": "gp3"<br>}</pre> | no |
| record | Value for Route53 entry | `string` | n/a | yes |
| sse\_algorithm | The type of encryption algorithm to use | `string` | `"aws:kms"` | no |
| ssh\_access | n/a | `list(any)` | n/a | yes |
| ssl\_certificate\_id | The ID of the SSL certificate from ACM | `string` | n/a | yes |
| subnet\_ids | A list of Subnet ids | `list(any)` | n/a | yes |
| volume\_size | Disk size for each EC2 instances | `string` | `250` | no |
| vpc\_cidr | The CIDR of the VPC | `list(any)` | n/a | yes |
| vpc\_id | The VPC id | `string` | n/a | yes |
| zone\_id | The Route53 zone for the record | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| address | URL of the Artifactory |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Related Projects

Check out these related projects.

- [terraform-aws-s3](https://github.com/jameswoolfenden/terraform-aws-s3) - S3 buckets

## Help

**Got a question?**

File a GitHub [issue](https://github.com/JamesWoolfenden/terraform-aws-artifactory/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/JamesWoolfenden/terraform-aws-artifactory/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2019-2021 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
[github]: https://github.com/jameswoolfenden
[linkedin]: https://www.linkedin.com/in/jameswoolfenden/
[twitter]: https://twitter.com/JimWoolfenden
[share_twitter]: https://twitter.com/intent/tweet/?text=terraform-aws-artifactory&url=https://github.com/JamesWoolfenden/terraform-aws-artifactory
[share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=terraform-aws-artifactory&url=https://github.com/JamesWoolfenden/terraform-aws-artifactory
[share_reddit]: https://reddit.com/submit/?url=https://github.com/JamesWoolfenden/terraform-aws-artifactory
[share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/JamesWoolfenden/terraform-aws-artifactory
[share_email]: mailto:?subject=terraform-aws-artifactory&body=https://github.com/JamesWoolfenden/terraform-aws-artifactory
