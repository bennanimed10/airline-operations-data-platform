"""
Profile the FAA airport base file (APT_BASE.csv).

Reports row count, column count, column names, first 5 records,
data types and top null counts. When the FAA data-structure file
is available, inferred types are shown next to the FAA-declared
type and nullability.

Usage:
    python src/ingestion/inspect_airports.py
    python src/ingestion/inspect_airports.py --file path/to/APT_BASE.csv
"""

from pathlib import Path
import argparse
import logging
import sys

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[2]

AIRPORT_FILE = (
    PROJECT_ROOT
    / "data"
    / "raw"
    / "airports"
    / "APT_BASE.csv"
)

STRUCTURE_FILE = (
    PROJECT_ROOT
    / "data"
    / "raw"
    / "airports"
    / "APT_CSV_DATA_STRUCTURE.csv"
)

# Name of APT_BASE in the "CSV File" column of the structure file
STRUCTURE_TABLE_NAME = "APT_BASE"

TOP_NULL_COUNT = 20


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)

logger = logging.getLogger(__name__)


# --------------------------------------------------
# Read source files
# --------------------------------------------------

def read_airports(airport_file):
    """Read the FAA airport CSV into a DataFrame."""

    if not airport_file.exists():
        raise FileNotFoundError(
            f"Airport file does not exist: {airport_file}"
        )

    logger.info("Reading airport file: %s", airport_file)

    df = pd.read_csv(
        airport_file,
        low_memory=False
    )

    if df.empty:
        raise ValueError(
            f"Airport file contains no records: {airport_file}"
        )

    logger.info(
        "Loaded %s rows and %s columns",
        f"{len(df):,}",
        f"{len(df.columns):,}"
    )

    return df


def read_structure(structure_file):
    """
    Read FAA-declared column definitions for APT_BASE.

    Returns None if the structure file is missing, so profiling
    still works with only APT_BASE.csv available.
    """

    if not structure_file.exists():
        logger.warning(
            "Structure file not found, skipping declared types: %s",
            structure_file
        )
        return None

    structure = pd.read_csv(structure_file)

    structure = structure[
        structure["CSV File"] == STRUCTURE_TABLE_NAME
    ]

    return structure.set_index("Column Name")[
        ["Data Type", "Max Length", "Nullable"]
    ]


# --------------------------------------------------
# Report sections
# --------------------------------------------------

def print_header(title):

    print("\n================================")
    print(title)
    print("================================")


def print_section(title):

    print(f"\n{title}")
    print("--------------------------------")


def print_summary(df):

    print_header("FAA AIRPORT DATASET SUMMARY")

    print(f"\nRows: {len(df):,}")
    print(f"Columns: {len(df.columns):,}")


def print_column_names(df):

    print_section("COLUMN NAMES")

    for column in df.columns:
        print(column)


def print_first_records(df):

    print_section("FIRST 5 RECORDS")

    print(df.head().to_string())


def print_data_types(df, structure):

    print_section("DATA TYPES")

    if structure is None:
        print(df.dtypes.to_string())
        return

    types = pd.DataFrame(
        {"inferred_type": df.dtypes.astype(str)}
    ).join(structure)

    print(types.to_string())

    # Flag drift between the file and the FAA layout
    missing = sorted(set(structure.index) - set(df.columns))
    unexpected = sorted(set(df.columns) - set(structure.index))

    if missing:
        logger.warning(
            "Columns declared by FAA but missing from file: %s",
            missing
        )

    if unexpected:
        logger.warning(
            "Columns in file but not declared by FAA: %s",
            unexpected
        )


def print_top_nulls(df, structure):

    print_section(f"NULL COUNTS - TOP {TOP_NULL_COUNT}")

    nulls = pd.DataFrame(
        {
            "null_count": df.isna().sum(),
            "null_percent": (
                df.isna().mean() * 100
            ).round(2),
        }
    )

    if structure is not None:
        nulls = nulls.join(structure["Nullable"])

    nulls = (
        nulls.sort_values("null_count", ascending=False)
             .head(TOP_NULL_COUNT)
    )

    print(nulls.to_string())


# --------------------------------------------------
# Main
# --------------------------------------------------

def parse_args():

    parser = argparse.ArgumentParser(
        description="Profile the FAA APT_BASE airport file."
    )

    parser.add_argument(
        "--file",
        type=Path,
        default=AIRPORT_FILE,
        help="Path to APT_BASE.csv"
    )

    parser.add_argument(
        "--structure-file",
        type=Path,
        default=STRUCTURE_FILE,
        help="Path to APT_CSV_DATA_STRUCTURE.csv"
    )

    return parser.parse_args()


def main():

    args = parse_args()

    try:
        df = read_airports(args.file)
        structure = read_structure(args.structure_file)

    except (FileNotFoundError, ValueError, KeyError) as error:
        logger.error("Airport profiling failed: %s", error)
        return 1

    print_summary(df)
    print_column_names(df)
    print_first_records(df)
    print_data_types(df, structure)
    print_top_nulls(df, structure)

    logger.info("Airport profiling completed successfully.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
