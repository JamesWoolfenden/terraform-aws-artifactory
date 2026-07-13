# terraform-aws-artifactory

[![Build Status](https://github.com/JamesWoolfenden/terraform-aws-artifactory/workflows/Verify%20and%20Bump/badge.svg?branch=master)](https://github.com/JamesWoolfenden/terraform-aws-artifactory)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-aws-artifactory.svg)](https://github.com/JamesWoolfenden/terraform-aws-artifactory/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-aws-artifactory.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-aws-artifactory/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.14.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![checkov](https://img.shields.io/badge/checkov-verified-brightgreen)](https://www.checkov.io/)

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

## Costs

```text
Monthly cost estimate

Project: JamesWoolfenden/terraform-aws-artifactory/example/examplea

 Name                                                           Monthly Qty  Unit                    Monthly Cost

 module.artifactory.aws_autoscaling_group.art
 └─ module.artifactory.aws_launch_configuration.master
    ├─ Instance usage (Linux/UNIX, on-demand, m4.xlarge)                730  hours                        $169.36
    ├─ EC2 detailed monitoring                                            7  metrics                        $2.10
    └─ root_block_device
       └─ Storage (general purpose SSD, gp2)                            250  GB                            $29.00

 module.artifactory.aws_db_instance.default
 ├─ Database instance                                                   730  hours                         $27.74
 └─ Database storage                                                      5  GB                             $0.67

 module.artifactory.aws_elb.web
 ├─ Classic load balancer                                               730  hours                         $21.46
 └─ Data processed                                        Monthly cost depends on usage: $0.0084 per GB

 module.artifactory.aws_s3_bucket.b
 └─ Standard
    ├─ Storage                                            Monthly cost depends on usage: $0.024 per GB
    ├─ PUT, COPY, POST, LIST requests                     Monthly cost depends on usage: $0.0053 per 1k requests
    ├─ GET, SELECT, and all other requests                Monthly cost depends on usage: $0.00042 per 1k requests
    ├─ Select data scanned                                Monthly cost depends on usage: $0.00225 per GB
    └─ Select data returned                               Monthly cost depends on usage: $0.0008 per GB

 OVERALL TOTAL                                                                                            $250.33
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
Turn off daily backups. Read Documentation provided [backups](https://www.jfrog.com/confluence/display/RTF/Managing+Backups).

**Note**: In this template as default S3 is default filestore and data is persisted in S3. If you keep daily backups on disk space (default 250Gb) will get occupied quickly.
Use an SSL Certificate with a valid wildcard to your artifactory as docker registry with subdomain method.

### Use Artifactory as backend

To to store state as an artifact in a given repository of Artifactory, see [https://www.terraform.io/docs/backends/types/artifactory.html](https://www.terraform.io/docs/backends/types/artifactory.html)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_autoscaling_attachment.asg_attachment_bar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [aws_autoscaling_group.art](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_instance.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.main_db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_instance_profile.art](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.art](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.art](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_key_pair.ssm_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_logging.b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.elb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.main_db_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_wafv2_web_acl.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [local_file.private_ssh](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.public_ssh](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.amazon_linux_2_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_artifactory_server_name"></a> [artifactory\_server\_name](#input\_artifactory\_server\_name) | Provide artifactory server name to be used in Nginx. e.g artifactory for artifactory.jfrog.team | `string` | `"artifactory"` | no |
| <a name="input_artifactory_sg_name"></a> [artifactory\_sg\_name](#input\_artifactory\_sg\_name) | Name for the Artifactory instance security group | `string` | `"artifactory_sg"` | no |
| <a name="input_autoscaling_group_name"></a> [autoscaling\_group\_name](#input\_autoscaling\_group\_name) | artifactory autoscaling group | `string` | `"artifactory autoscaling group"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | AWS S3 Bucket name | `string` | n/a | yes |
| <a name="input_database"></a> [database](#input\_database) | RDS database configuration for Artifactory | <pre>object({<br/>    name                = optional(string, "artdb")<br/>    user                = optional(string, "artifactory")<br/>    password            = string<br/>    instance_class      = optional(string, "db.t2.small")<br/>    allocated_storage   = optional(string, "5")<br/>    storage_type        = optional(string, "gp2")<br/>    engine              = optional(string, "mysql")<br/>    engine_version      = optional(string, "5.5")<br/>    skip_final_snapshot = optional(bool, true)<br/>    monitoring_interval = optional(number, 30)<br/>    monitoring_role_arn = string<br/>  })</pre> | n/a | yes |
| <a name="input_dns"></a> [dns](#input\_dns) | Route53 DNS configuration for the Artifactory endpoint | <pre>object({<br/>    zone_id = string<br/>    record  = string<br/>  })</pre> | n/a | yes |
| <a name="input_instance"></a> [instance](#input\_instance) | EC2 instance configuration for the Artifactory launch template | <pre>object({<br/>    key_name           = optional(string, "jfrog")<br/>    volume_size        = optional(number, 250)<br/>    instance_type      = string<br/>    extra_java_options = optional(string, "-server -Xms2g -Xmx14g -Xss256k -XX:+UseG1GC -XX:OnOutOfMemoryError=\\\\"kill -9 %p\\\\"")<br/>  })</pre> | n/a | yes |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | KMS key ARN or alias for encrypting resources | `string` | n/a | yes |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | Load balancer name and TLS certificate for the Artifactory endpoint | <pre>object({<br/>    name               = optional(string, "artifactoryelb")<br/>    ssl_certificate_id = string<br/>  })</pre> | n/a | yes |
| <a name="input_master_key"></a> [master\_key](#input\_master\_key) | Master key for Artifactory cluster. Generate master.key using command '$openssl rand -hex 16' | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | VPC and subnet configuration for Artifactory, its load balancer, and its database | <pre>object({<br/>    vpc_id         = string<br/>    vpc_cidr       = list(string)<br/>    subnet_ids     = list(string)<br/>    alb_subnet_ids = optional(list(string), [])<br/>    access_cidr    = list(string)<br/>    ssh_access     = list(string)<br/><br/>    # No default: whether instances get public IPs is a real security<br/>    # tradeoff (false requires subnet_ids to be private with NAT egress for<br/>    # package installation at boot) that every caller must decide explicitly<br/>    # rather than silently inherit.<br/>    associate_public_ip = bool<br/>  })</pre> | n/a | yes |
| <a name="input_profile_name"></a> [profile\_name](#input\_profile\_name) | Instance profile name | `string` | `"artifactory"` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | The type of encryption algorithm to use | `string` | `"aws:kms"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_address"></a> [address](#output\_address) | URL of the Artifactory |
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | ARN of the Artifactory autoscaling group |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | Name of the Artifactory autoscaling group |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the S3 bucket used for Artifactory binary storage |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Name of the S3 bucket used for Artifactory binary storage |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | ARN of the Artifactory RDS instance |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | Connection endpoint (host:port) of the Artifactory RDS instance |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | Identifier of the Artifactory RDS instance |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role attached to the Artifactory instances |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role attached to the Artifactory instances |
| <a name="output_key_pair_name"></a> [key\_pair\_name](#output\_key\_pair\_name) | Name of the generated EC2 key pair |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | ID of the Artifactory launch template |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | ARN of the Artifactory application load balancer |
| <a name="output_load_balancer_security_group_id"></a> [load\_balancer\_security\_group\_id](#output\_load\_balancer\_security\_group\_id) | ID of the security group attached to the load balancer |
| <a name="output_load_balancer_zone_id"></a> [load\_balancer\_zone\_id](#output\_load\_balancer\_zone\_id) | Route53 hosted zone ID of the load balancer, for creating alias records |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group attached to the Artifactory instances |
| <a name="output_waf_web_acl_arn"></a> [waf\_web\_acl\_arn](#output\_waf\_web\_acl\_arn) | ARN of the WAFv2 web ACL protecting the load balancer |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Policy

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role — full permissions for terraform apply
resource "aws_iam_policy" "terraform_pike" {
  name_prefix = "terraform_pike"
  path        = "/"
  description = "Pike Autogenerated policy from IAC"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "amplify:DisassociateWebACL",
                "amplify:GetWebACLForResource"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "apigateway:SetWebACL"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "apprunner:AssociateWebAcl",
                "apprunner:DescribeWebAclForService",
                "apprunner:DisassociateWebAcl",
                "apprunner:ListAssociatedServicesForWebAcl"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "appsync:SetWebACL"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Action": [
                "autoscaling:AttachLoadBalancerTargetGroups",
                "autoscaling:AttachLoadBalancers",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:CreateOrUpdateTags",
                "autoscaling:DeleteAutoScalingGroup",
                "autoscaling:DeleteTags",
                "autoscaling:Describe*",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DetachLoadBalancerTargetGroups",
                "autoscaling:DetachLoadBalancers",
                "autoscaling:UpdateAutoScalingGroup"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor5",
            "Effect": "Allow",
            "Action": [
                "cognito-idp:AssociateWebACL",
                "cognito-idp:DisassociateWebACL",
                "cognito-idp:GetWebACLForResource",
                "cognito-idp:ListResourcesForWebACL"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor6",
            "Effect": "Allow",
            "Action": [
                "ec2:AssociateVerifiedAccessInstanceWebAcl",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateKeyPair",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateLaunchTemplateVersion",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteKeyPair",
                "ec2:DeleteLaunchTemplate",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteSecurityGroup",
                "ec2:Describe*",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVerifiedAccessInstanceWebAclAssociations",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcs",
                "ec2:DetachNetworkInterface",
                "ec2:DisassociateVerifiedAccessInstanceWebAcl",
                "ec2:Get*",
                "ec2:GetVerifiedAccessInstanceWebAcl",
                "ec2:ImportKeyPair",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RunInstances"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor7",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListenerAttributes",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyListenerAttributes",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetWebACL",
                "elasticloadbalancing:SetWebAcl"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor8",
            "Effect": "Allow",
            "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:CreateRole",
                "iam:CreateServiceLinkedRole",
                "iam:DeleteInstanceProfile",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:GetInstanceProfile",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:ListRolePolicies",
                "iam:ListRoles",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:RemoveRoleFromInstanceProfile"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor9",
            "Effect": "Allow",
            "Action": [
                "logs:AssociateKmsKey",
                "logs:CreateLogGroup",
                "logs:DeleteLogGroup",
                "logs:DeleteRetentionPolicy",
                "logs:DescribeLogGroups",
                "logs:DisassociateKmsKey",
                "logs:ListTagsForResource",
                "logs:ListTagsLogGroup",
                "logs:PutRetentionPolicy"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor10",
            "Effect": "Allow",
            "Action": [
                "managed-fleets:DeleteAutoScalingGroup",
                "managed-fleets:DeregisterAutoScalingGroup",
                "managed-fleets:Get*",
                "managed-fleets:RegisterAutoScalingGroup",
                "managed-fleets:UpdateAutoScalingGroup"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor11",
            "Effect": "Allow",
            "Action": [
                "rds:CreateDBInstance",
                "rds:CreateDBSnapshot",
                "rds:CreateDBSubnetGroup",
                "rds:DeleteDBInstance",
                "rds:DeleteDBSubnetGroup",
                "rds:DescribeDBClusters",
                "rds:DescribeDBEngineVersions",
                "rds:DescribeDBInstanceAutomatedBackups",
                "rds:DescribeDBInstances",
                "rds:DescribeDBParameterGroups",
                "rds:DescribeDBSubnetGroups",
                "rds:ListTagsForResource",
                "rds:ModifyDBInstance",
                "rds:ModifyDBSubnetGroup",
                "rds:RebootDBInstance"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor12",
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets",
                "route53:GetChange",
                "route53:GetHostedZone",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor13",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:DeleteBucketPolicy",
                "s3:GetAccelerateConfiguration",
                "s3:GetBucketAcl",
                "s3:GetBucketCORS",
                "s3:GetBucketLogging",
                "s3:GetBucketObjectLockConfiguration",
                "s3:GetBucketPolicy",
                "s3:GetBucketPublicAccessBlock",
                "s3:GetBucketRequestPayment",
                "s3:GetBucketTagging",
                "s3:GetBucketVersioning",
                "s3:GetBucketWebsite",
                "s3:GetEncryptionConfiguration",
                "s3:GetLifecycleConfiguration",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetReplicationConfiguration",
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "s3:PutBucketAcl",
                "s3:PutBucketLogging",
                "s3:PutBucketPolicy",
                "s3:PutBucketPublicAccessBlock",
                "s3:PutBucketVersioning",
                "s3:PutEncryptionConfiguration",
                "s3:PutLifecycleConfiguration"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor14",
            "Effect": "Allow",
            "Action": [
                "ssm:DeleteParameter",
                "ssm:Get*",
                "ssm:PutParameter"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor15",
            "Effect": "Allow",
            "Action": [
                "wafv2:AssociateWebACL",
                "wafv2:CreateWebACL",
                "wafv2:DeleteWebACL",
                "wafv2:DisassociateWebACL",
                "wafv2:GetLoggingConfiguration",
                "wafv2:GetPermissionPolicy",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:ListTagsForResource",
                "wafv2:PutLoggingConfiguration",
                "wafv2:PutPermissionPolicy",
                "wafv2:UpdateWebACL"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}

# plan role — read-only permissions for terraform plan
resource "aws_iam_policy" "terraform_pike_plan" {
  name_prefix = "terraform_pike_plan"
  path        = "/"
  description = "Pike Autogenerated policy from IAC"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "amplify:GetWebACLForResource"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "apigateway:SetWebACL"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "apprunner:AssociateWebAcl",
                "apprunner:DescribeWebAclForService",
                "apprunner:DisassociateWebAcl"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "appsync:SetWebACL"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Action": [
                "autoscaling:Describe*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor5",
            "Effect": "Allow",
            "Action": [
                "cognito-idp:AssociateWebACL",
                "cognito-idp:DisassociateWebACL",
                "cognito-idp:GetWebACLForResource"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor6",
            "Effect": "Allow",
            "Action": [
                "ec2:AssociateVerifiedAccessInstanceWebAcl",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVerifiedAccessInstanceWebAclAssociations",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcs",
                "ec2:DisassociateVerifiedAccessInstanceWebAcl",
                "ec2:GetVerifiedAccessInstanceWebAcl"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor7",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:SetWebACL"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor8",
            "Effect": "Allow",
            "Action": [
                "rds:DescribeDBInstances"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor9",
            "Effect": "Allow",
            "Action": [
                "s3:GetAccelerateConfiguration",
                "s3:GetBucketAcl",
                "s3:GetBucketCORS",
                "s3:GetBucketLogging",
                "s3:GetBucketObjectLockConfiguration",
                "s3:GetBucketPolicy",
                "s3:GetBucketRequestPayment",
                "s3:GetBucketTagging",
                "s3:GetBucketVersioning",
                "s3:GetBucketWebsite",
                "s3:GetEncryptionConfiguration",
                "s3:GetLifecycleConfiguration",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetReplicationConfiguration",
                "s3:ListBucket"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor10",
            "Effect": "Allow",
            "Action": [
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

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

Copyright © 2019-2026 James Woolfenden

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
