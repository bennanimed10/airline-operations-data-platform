#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

source "$PROJECT_ROOT/config/project.env"


YEAR=2026
MONTH=07

LOCAL_FILE="$PROJECT_ROOT/data/raw/flights/flights_2026_07.zip"

S3_PATH="s3://$S3_BUCKET/landing/flights/year=$YEAR/month=$MONTH/"


echo "========================================"
echo "AirOps - Flight Upload"
echo "========================================"

echo "Local file:"
echo "$LOCAL_FILE"

echo ""
echo "Destination:"
echo "$S3_PATH"


# Check file exists locally
if [ ! -f "$LOCAL_FILE" ]; then
    echo "ERROR: Source file does not exist."
    exit 1
fi


echo ""
echo "Uploading..."

aws s3 cp \
    "$LOCAL_FILE" \
    "${S3_PATH}flights_2026_07.zip"


echo ""
echo "Verifying upload..."

aws s3 ls "$S3_PATH"


echo ""
echo "========================================"
echo "Upload completed successfully."
echo "========================================"