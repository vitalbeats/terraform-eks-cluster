/*
resource "aws_kms_key" "cloudwatch" {
  count       = var.cluster-enable-cloudwatch ? 1 : 0
  description = "KMS key for CloudWatch"
  policy      = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "cloudwatch-kms",
  "Statement" : [ {
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Action" : "kms:*",
      "Resource" : "*"
    },
    {
      "Effect": "Allow",
      "Principal": { "Service": "logs.${var.cluster-region}.amazonaws.com" },
      "Action": [ 
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "*"
    }  
  ]
}
  POLICY
}

resource "aws_cloudwatch_log_group" "this" {
  count             = var.cluster-enable-cloudwatch ? 1 : 0
  name              = "/aws/eks/${var.cluster-name}/cluster"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.cloudwatch[count.index].id
}

*/
