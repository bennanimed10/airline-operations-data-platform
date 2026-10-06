from pathlib import Path
import zipfile
import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[2]

ZIP_FILE = (
    PROJECT_ROOT
    / "data"
    / "raw"
    / "flights"
    / "flights_2026_07.zip"
)


# --------------------------------------------------
# Load source data
# --------------------------------------------------

with zipfile.ZipFile(ZIP_FILE, "r") as zip_file:

    csv_file = [
        name
        for name in zip_file.namelist()
        if name.lower().endswith(".csv")
    ][0]

    with zip_file.open(csv_file) as file:
        df = pd.read_csv(file, low_memory=False)


# Remove empty CSV artifact column
df = df.drop(
    columns=[
        column
        for column in df.columns
        if column.startswith("Unnamed:")
    ],
    errors="ignore"
)


print("\n==============================")
print("FLIGHT DATA VALIDATION")
print("==============================")


validation_results = []


def check(name, failed_rows):

    failed_count = len(failed_rows)

    status = "PASS" if failed_count == 0 else "FAIL"

    validation_results.append(
        {
            "check": name,
            "status": status,
            "failed_rows": failed_count,
        }
    )

    print(
        f"{status:5} | "
        f"{name:55} | "
        f"Failures: {failed_count:,}"
    )


# --------------------------------------------------
# Rule 1
# FlightDate must exist
# --------------------------------------------------

check(
    "FlightDate must not be NULL",
    df[df["FlightDate"].isna()]
)


# --------------------------------------------------
# Rule 2
# Origin airport must exist
# --------------------------------------------------

check(
    "Origin must not be NULL",
    df[df["Origin"].isna()]
)


# --------------------------------------------------
# Rule 3
# Destination airport must exist
# --------------------------------------------------

check(
    "Destination must not be NULL",
    df[df["Dest"].isna()]
)


# --------------------------------------------------
# Rule 4
# Origin and destination cannot be identical
# --------------------------------------------------

check(
    "Origin and destination must be different",
    df[df["Origin"] == df["Dest"]]
)


# --------------------------------------------------
# Rule 5
# Distance must be positive
# --------------------------------------------------

check(
    "Distance must be greater than zero",
    df[df["Distance"] <= 0]
)


# --------------------------------------------------
# Rule 6
# Cancellation flag must be valid
# --------------------------------------------------

check(
    "Cancelled must be 0 or 1",
    df[~df["Cancelled"].isin([0, 1])]
)


# --------------------------------------------------
# Rule 7
# Cancelled flights should have cancellation code
# --------------------------------------------------

check(
    "Cancelled flights must have CancellationCode",
    df[
        (df["Cancelled"] == 1)
        & (df["CancellationCode"].isna())
    ]
)


# --------------------------------------------------
# Rule 8
# Non-cancelled flights should not have cancellation code
# --------------------------------------------------

check(
    "Non-cancelled flights should not have CancellationCode",
    df[
        (df["Cancelled"] == 0)
        & (df["CancellationCode"].notna())
    ]
)


# --------------------------------------------------
# Rule 9
# Normal completed flights should have arrival delay
# --------------------------------------------------

check(
    "Completed non-diverted flights must have ArrDelay",
    df[
        (df["Cancelled"] == 0)
        & (df["Diverted"] == 0)
        & (df["ArrDelay"].isna())
    ]
)


# --------------------------------------------------
# Rule 10
# Duplicate complete rows
# --------------------------------------------------

check(
    "Dataset must not contain duplicate rows",
    df[df.duplicated()]
)


# --------------------------------------------------
# Summary
# --------------------------------------------------

results_df = pd.DataFrame(validation_results)

print("\n==============================")
print("VALIDATION SUMMARY")
print("==============================")

print(results_df.to_string(index=False))