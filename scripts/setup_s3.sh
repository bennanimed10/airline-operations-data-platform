#!/bin/bash

set -euo pipefail

# Get project root
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Load configuration
source "$PROJECT_ROOT/config/project.env"

echo "========================================"
echo "AirOps - S3 Setup"
echo "========================================"

echo "Region: $AWS_REGION"
echo "Bucket: $S3_BUCKET"

# Check if bucket already exists
if aws s3api head-bucket \
    --bucket "$S3_BUCKET" 2>/dev/null; then

    echo "Bucket already exists."

else

    echo "Creating bucket..."

    if [ "$AWS_REGION" = "us-east-1" ]; then

        aws s3api create-bucket \
            --bucket "$S3_BUCKET" \
            --region "$AWS_REGION"

    else

        aws s3api create-bucket \
            --bucket "$S3_BUCKET" \
            --region "$AWS_REGION" \
            --create-bucket-configuration \
            LocationConstraint="$AWS_REGION"

    fi

fi


echo "Enabling public access protection..."

aws s3api put-public-access-block \
    --bucket "$S3_BUCKET" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"


echo "Enabling bucket versioning..."

aws s3api put-bucket-versioning \
    --bucket "$S3_BUCKET" \
    --versioning-configuration Status=Enabled


echo "========================================"
echo "S3 setup completed successfully."
echo "========================================"