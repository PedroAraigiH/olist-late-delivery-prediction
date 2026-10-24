"""Load the Olist CSV files into a SQLite database (one table per CSV file)"""
import sqlite3
from pathlib import Path

import pandas as pd

RAW_DIR = Path("data/raw")
DB_PATH = Path("data/olist.db")


def table_name(csv_path):
    """olist_orders_dataset.csv -> orders"""
    return csv_path.stem.replace("olist_", "").replace("_dataset", "")


def load_all():
    csv_files = sorted(RAW_DIR.glob("*.csv"))
    if not csv_files:
        raise FileNotFoundError(f"No CSV files found in {RAW_DIR} - download the dataset first.")

    DB_PATH.parent.mkdir(exist_ok=True)
    conn = sqlite3.connect(DB_PATH)          # creates the file if it does not exist
    for path in csv_files:
        df = pd.read_csv(path)
        df.to_sql(table_name(path), conn, if_exists="replace", index=False)
        print(f"{table_name(path):35s} {len(df):>8} rows")
    conn.close()


if __name__ == "__main__":
    load_all()
