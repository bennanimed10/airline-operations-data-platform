#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

source "$PROJECT_ROOT/config/project.env"

YEAR=2026
MONTH=07

LOCAL_FILE="$PROJECT_ROOT/data/processed/flights/flights_2026_07.csv.gz"

S3_PATH="s3://$S3_BUCKET/prepared/flights/year=$YEAR/month=$MONTH/"


if [ ! -f "$LOCAL_FILE" ]; then
    echo "ERROR: Prepared flight file does not exist."
    exit 1
fi


echo "Uploading Snowflake-ready flight file..."

aws s3 cp \
    "$LOCAL_FILE" \
    "${S3_PATH}flights_2026_07.csv.gz"


echo ""
echo "Verifying..."

aws s3 ls "$S3_PATH"