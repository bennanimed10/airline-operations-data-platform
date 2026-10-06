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
# Read CSV from ZIP
# --------------------------------------------------

with zipfile.ZipFile(ZIP_FILE, "r") as zip_file:

    csv_file = [
        name
        for name in zip_file.namelist()
        if name.lower().endswith(".csv")
    ][0]

    with zip_file.open(csv_file) as file:
        df = pd.read_csv(file, low_memory=False)


# --------------------------------------------------
# Remove empty CSV artifact column
# --------------------------------------------------

df = df.drop(
    columns=[
        column
        for column in df.columns
        if column.startswith("Unnamed:")
    ],
    errors="ignore"
)


print("\n================================")
print("FLIGHT DATA QUALITY PROFILE")
print("================================")


# --------------------------------------------------
# Dataset size
# --------------------------------------------------

print(f"\nTotal rows: {len(df):,}")
print(f"Total columns: {len(df.columns):,}")


# --------------------------------------------------
# Duplicate rows
# --------------------------------------------------

duplicate_rows = df.duplicated().sum()

print(f"\nDuplicate rows: {duplicate_rows:,}")


# --------------------------------------------------
# Important columns
# --------------------------------------------------

important_columns = [
    "FlightDate",
    "Reporting_Airline",
    "Flight_Number_Reporting_Airline",
    "Tail_Number",
    "Origin",
    "Dest",
    "CRSDepTime",
    "DepTime",
    "DepDelay",
    "CRSArrTime",
    "ArrTime",
    "ArrDelay",
    "Cancelled",
    "CancellationCode",
    "Diverted",
    "Distance",
    "CarrierDelay",
    "WeatherDelay",
    "NASDelay",
    "SecurityDelay",
    "LateAircraftDelay",
]


print("\nNULL COUNTS")
print("--------------------------------")

for column in important_columns:

    null_count = df[column].isna().sum()

    null_percent = (
        null_count / len(df)
    ) * 100

    print(
        f"{column:40} "
        f"{null_count:10,} "
        f"{null_percent:6.2f}%"
    )


# --------------------------------------------------
# Cancellation counts
# --------------------------------------------------

print("\nCANCELLED FLIGHTS")
print("--------------------------------")

print(
    df["Cancelled"]
    .value_counts(dropna=False)
)


# --------------------------------------------------
# Diverted counts
# --------------------------------------------------

print("\nDIVERTED FLIGHTS")
print("--------------------------------")

print(
    df["Diverted"]
    .value_counts(dropna=False)
)


# --------------------------------------------------
# Airlines
# --------------------------------------------------

print("\nAIRLINES")
print("--------------------------------")

print(
    df["Reporting_Airline"]
    .value_counts()
)


# --------------------------------------------------
# Top origin airports
# --------------------------------------------------

print("\nTOP 10 ORIGIN AIRPORTS")
print("--------------------------------")

print(
    df["Origin"]
    .value_counts()
    .head(10)
)


# --------------------------------------------------
# Delay statistics
# --------------------------------------------------

print("\nDEPARTURE DELAY STATISTICS")
print("--------------------------------")

print(
    df["DepDelay"]
    .describe()
)


print("\nARRIVAL DELAY STATISTICS")
print("--------------------------------")

print(
    df["ArrDelay"]
    .describe()
)