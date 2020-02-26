# EKS Getting Started Guide Configuration

This is the full configuration from https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html

See that guide for additional information.

NOTE: This full configuration utilizes the [Terraform http provider](https://www.terraform.io/docs/providers/http/index.html) to call out to icanhazip.com to determine your local workstation external IP for easily configuring EC2 Security Group access to the Kubernetes master servers. Feel free to replace this as necessary.

## Prerequisites

To provision clusters with this repository, you will need the following tools:

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
- [Terraform](https://www.terraform.io/downloads.html)

With these tools installed, you will need to set them up with your AWS IAM credentials. [Login via IAM](https://vitalbeats-engineering.signin.aws.amazon.com/console) and navigate to your user credentials. The URL will be something like [https://console.aws.amazon.com/iam/home?region=eu-west-1#/users/user.name@vitalbeats.com?section=security_credentials](https://console.aws.amazon.com/iam/home?region=eu-west-1#/users). Create a new access key (you are only allowed 2 active at a time), and record the access key ID and secret, you will need this for the next step. Then open a terminal and run:

```
$ aws configure
AWS Access Key ID [None]: Example_Access_ID
AWS Secret Access Key [None]: Example_Access_Secret
Default region name [None]: eu-west-1
Default output format [None]: json
```

With this configured, you can now access AWS. You can confirm this by running `aws sts get-caller-identity`. It will return you a JSON result which contains your IAM username in the ARN field.

With this repository checked out, you will need to first initialise and download terraform providers. This can be done by running `terraform init`.

# TODO

- EC2 SSH access (aws_eks_node_group can set remote_access.ec2_ssh_key_name), to be able to access the kubelets themselves.
- CloudWatch or other log aggregation.
- Amazon EBS + relevant storage driver and sane defaults.
