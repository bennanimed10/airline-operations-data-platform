from pathlib import Path
import zipfile
import pandas as pd


# ---------------------------------------------------
# 1. Locate the raw BTS ZIP file
# ---------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[2]

ZIP_FILE = (
    PROJECT_ROOT
    / "data"
    / "raw"
    / "flights"
    / "flights_2026_07.zip"
)

print(f"Reading file: {ZIP_FILE}")


# ---------------------------------------------------
# 2. Open the ZIP file
# ---------------------------------------------------

with zipfile.ZipFile(ZIP_FILE, "r") as zip_file:

    # Show files contained inside the ZIP
    files = zip_file.namelist()

    print("\nFiles inside ZIP:")
    for file in files:
        print(f" - {file}")


    # ------------------------------------------------
    # 3. Find the CSV automatically
    # ------------------------------------------------

    csv_files = [
        file
        for file in files
        if file.lower().endswith(".csv")
    ]

    if not csv_files:
        raise ValueError("No CSV file found inside ZIP.")

    csv_file = csv_files[0]

    print(f"\nUsing CSV: {csv_file}")


    # ------------------------------------------------
    # 4. Read flight data into pandas
    # ------------------------------------------------

    with zip_file.open(csv_file) as file:
        df = pd.read_csv(file, low_memory=False)


# ---------------------------------------------------
# 5. Basic inspection
# ---------------------------------------------------

print("\n==============================")
print("FLIGHT DATASET SUMMARY")
print("==============================")

print(f"\nRows: {len(df):,}")
print(f"Columns: {len(df.columns):,}")


print("\nCOLUMN NAMES")
print("------------------------------")

for column in df.columns:
    print(column)


print("\nFIRST 5 RECORDS")
print("------------------------------")

print(df.head())


print("\nDATA TYPES")
print("------------------------------")

print(df.dtypes)