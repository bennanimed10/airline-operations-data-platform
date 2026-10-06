#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

source "$PROJECT_ROOT/config/project.env"


CYCLE=2026-10-01

FILE_NAME="APT_BASE.csv"

LOCAL_FILE="$PROJECT_ROOT/data/raw/airports/$FILE_NAME"

S3_PATH="s3://$S3_BUCKET/landing/airports/cycle=$CYCLE/"

S3_KEY="landing/airports/cycle=$CYCLE/$FILE_NAME"


echo "========================================"
echo "AirOps - FAA Airport Upload"
echo "========================================"

echo "Local file:"
echo "$LOCAL_FILE"

echo ""
echo "Destination:"
echo "${S3_PATH}${FILE_NAME}"


# Check file exists locally
if [ ! -f "$LOCAL_FILE" ]; then
    echo "ERROR: Source file does not exist."
    exit 1
fi


echo ""
echo "Uploading..."

aws s3 cp \
    "$LOCAL_FILE" \
    "${S3_PATH}${FILE_NAME}"


echo ""
echo "Verifying upload..."

LOCAL_SIZE=$(wc -c < "$LOCAL_FILE" | tr -d ' ')

S3_SIZE=$(aws s3api head-object \
    --bucket "$S3_BUCKET" \
    --key "$S3_KEY" \
    --query ContentLength \
    --output text)

echo "Local size: $LOCAL_SIZE bytes"
echo "S3 size:    $S3_SIZE bytes"

if [ "$LOCAL_SIZE" != "$S3_SIZE" ]; then
    echo "ERROR: S3 object size does not match local file."
    exit 1
fi

aws s3 ls "$S3_PATH"


echo ""
echo "========================================"
echo "Upload completed successfully."
echo "========================================"
