resource "aws_dynamodb_table" "nautilus-table" {
  name           = var.KKE_TABLE_NAME
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "matchId"

  attribute {
    name = "matchId"
    type = "S"
  }
}

resource "aws_iam_role" "nautilus-role" {
  name = var.KKE_ROLE_NAME

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "db-readonly-policy" {
  statement {
    sid    = "DynamoDBReadOnlyActions"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      aws_dynamodb_table.nautilus-table.arn
    ]
  }
}

resource "aws_iam_policy" "nautilus-readonly-policy" {
  name        = var.KKE_POLICY_NAME
  description = "Provides read-only access to a specific DynamoDB table"
  policy      = data.aws_iam_policy_document.db-readonly-policy.json
}

resource "aws_iam_role_policy_attachment" "attach-readonly" {
  role       = aws_iam_role.nautilus-role.name
  policy_arn = aws_iam_policy.nautilus-readonly-policy.arn
}
