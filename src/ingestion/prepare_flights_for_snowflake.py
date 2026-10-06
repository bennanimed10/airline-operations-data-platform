from pathlib import Path
import zipfile
import gzip
import csv


PROJECT_ROOT = Path(__file__).resolve().parents[2]

ZIP_FILE = (
    PROJECT_ROOT
    / "data"
    / "raw"
    / "flights"
    / "flights_2026_07.zip"
)

OUTPUT_DIR = (
    PROJECT_ROOT
    / "data"
    / "processed"
    / "flights"
)

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

OUTPUT_FILE = OUTPUT_DIR / "flights_2026_07.csv.gz"


with zipfile.ZipFile(ZIP_FILE, "r") as zip_file:

    csv_files = [
        name
        for name in zip_file.namelist()
        if name.lower().endswith(".csv")
    ]

    if not csv_files:
        raise ValueError("No CSV file found inside ZIP.")

    csv_file = csv_files[0]

    print(f"Source CSV: {csv_file}")
    print(f"Output: {OUTPUT_FILE}")

    with zip_file.open(csv_file, "r") as source_binary:

        source_text = (
            line.decode("utf-8-sig")
            for line in source_binary
        )

        reader = csv.reader(source_text)

        with gzip.open(
            OUTPUT_FILE,
            "wt",
            newline="",
            encoding="utf-8"
        ) as destination:

            writer = csv.writer(destination)

            # Read header
            header = next(reader)

            # BTS file contains an empty trailing column.
            # Remove it from the prepared dataset.
            if header and header[-1].strip() == "":
                header = header[:-1]
                remove_last_column = True

                print(
                    "Removed empty trailing source column."
                )

            else:
                remove_last_column = False

            writer.writerow(header)

            row_count = 0

            for row in reader:

                if remove_last_column and len(row) > len(header):
                    row = row[:len(header)]

                writer.writerow(row)

                row_count += 1


print(f"Rows prepared: {row_count:,}")
print(
    f"Columns prepared: {len(header):,}"
)
print("Snowflake-ready file created successfully.")