#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

ROLE_NAME="AirOpsSnowflakeRole"

SNOWFLAKE_IAM_USER_ARN="arn:aws:iam::916743723336:user/fpj82000-s"
SNOWFLAKE_EXTERNAL_ID="IS66226_SFCRole=2_4fTUm7yJObtzS437t8P0t4ocROg="

cat > "$PROJECT_ROOT/aws/iam/trust-policy-snowflake.json" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "$SNOWFLAKE_IAM_USER_ARN"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "$SNOWFLAKE_EXTERNAL_ID"
        }
      }
    }
  ]
}
EOF

aws iam update-assume-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-document \
  "file://$PROJECT_ROOT/aws/iam/trust-policy-snowflake.json"

echo "Snowflake trust policy updated successfully."