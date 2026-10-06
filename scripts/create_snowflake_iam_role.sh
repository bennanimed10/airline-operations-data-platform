#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

source "$PROJECT_ROOT/config/project.env"

ROLE_NAME="AirOpsSnowflakeRole"

CURRENT_PRINCIPAL=$(aws sts get-caller-identity --query Arn --output text)

echo "========================================"
echo "AirOps - Snowflake IAM Role Setup"
echo "========================================"

echo "Role: $ROLE_NAME"
echo "Bucket: $S3_BUCKET"


# -----------------------------------------
# Temporary trust policy
#
# We will replace this later with
# Snowflake's IAM principal + external ID.
# -----------------------------------------

cat > "$PROJECT_ROOT/aws/iam/trust-policy-temp.json" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "$CURRENT_PRINCIPAL"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF


# -----------------------------------------
# S3 permissions
# -----------------------------------------

cat > "$PROJECT_ROOT/aws/iam/s3-read-policy.json" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::$S3_BUCKET"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::$S3_BUCKET/*"
      ]
    }
  ]
}
EOF


# -----------------------------------------
# Create IAM role if it doesn't exist
# -----------------------------------------

if aws iam get-role \
    --role-name "$ROLE_NAME" > /dev/null 2>&1; then

    echo "IAM role already exists."

else

    echo "Creating IAM role..."

    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document \
        "file://$PROJECT_ROOT/aws/iam/trust-policy-temp.json"

fi


# -----------------------------------------
# Attach S3 policy
# -----------------------------------------

echo "Attaching S3 read policy..."

aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name AirOpsS3ReadPolicy \
    --policy-document \
    "file://$PROJECT_ROOT/aws/iam/s3-read-policy.json"


echo ""
echo "IAM ROLE ARN"
echo "----------------------------------------"

aws iam get-role \
    --role-name "$ROLE_NAME" \
    --query 'Role.Arn' \
    --output text


echo ""
echo "========================================"
echo "IAM role setup complete."
echo "========================================"