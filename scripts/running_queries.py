#!/usr/bin/env python3

import os
import re
import pandas as pd
from sqlalchemy import create_engine

# -------------------------------------------------
# 1) Database Connection String
#    Adjust to your local or Supabase credentials.
# -------------------------------------------------
conn_str = "postgresql://postgres.ofzmjajybuxefodhbuvq:Nb2pndua123@aws-0-us-east-1.pooler.supabase.com:6543/postgres"
engine = create_engine(conn_str)


def load_queries_from_file(file_path: str):
    """
    Reads a queries.sql file, parses out:
      - Query name (from lines beginning with '-- Query:')
      - Query purpose (from lines beginning with '-- Purpose:')
      - The SQL statement (until a semicolon)

    Returns a list of dicts, each containing:
      {
        'name': str (e.g., "Retrieve all patient records"),
        'purpose': str (brief description),
        'sql': str (the actual query)
      }
    """
    queries = []
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    current_query_name = None
    current_query_purpose = []
    current_sql_lines = []

    for line in lines:
        line_stripped = line.strip()

        # Detect a query name
        if line_stripped.startswith("-- Query:"):
            # Save any existing query block before starting a new one
            if current_sql_lines:
                # finalize the previous query
                full_sql = "\n".join(current_sql_lines).strip()
                if full_sql.endswith(";"):
                    full_sql = full_sql[:-1].strip()  # remove trailing semicolon
                queries.append({
                    "name": current_query_name,
                    "purpose": " ".join(current_query_purpose),
                    "sql": full_sql
                })
                current_sql_lines = []
                current_query_purpose = []

            # Extract the query name (everything after '-- Query:')
            current_query_name = line_stripped.replace("-- Query:", "").strip()

        # Detect a query purpose
        elif line_stripped.startswith("-- Purpose:"):
            # Append to the list of lines describing the purpose
            purpose_text = line_stripped.replace("-- Purpose:", "").strip()
            current_query_purpose.append(purpose_text)

        # If it's a SQL line or something else
        elif not line_stripped.startswith("--") and line_stripped != "":
            current_sql_lines.append(line.rstrip("\n"))

    # After the loop, we might have a leftover query
    if current_sql_lines:
        full_sql = "\n".join(current_sql_lines).strip()
        if full_sql.endswith(";"):
            full_sql = full_sql[:-1].strip()  # remove trailing semicolon
        queries.append({
            "name": current_query_name,
            "purpose": " ".join(current_query_purpose),
            "sql": full_sql
        })

    return queries


def run_query(query_dict):
    """
    Runs a single query (SELECT or otherwise).
    If it's a SELECT, we print the DataFrame.
    Otherwise, we print rowcount or success info.
    """
    name = query_dict.get("name", "No Name")
    purpose = query_dict.get("purpose", "No Purpose Provided")
    sql = query_dict["sql"]

    print("=" * 60)
    print(f"Query Name: {name}")
    print(f"Purpose   : {purpose}")
    print(f"SQL       :\n{sql}")
    print("-" * 60)

    # Determine if this is likely a SELECT or not
    first_word = sql.strip().split()[0].upper()
    if first_word == "SELECT":
        # Attempt to fetch data as a DataFrame
        try:
            df_result = pd.read_sql(sql, engine)
            print("Result:")
            print(df_result)
        except Exception as e:
            print("Error fetching SELECT query:\n", e)
    else:
        # For CREATE, INSERT, UPDATE, etc.
        try:
            with engine.begin() as conn:
                result = conn.execute(sql)
                rowcount = result.rowcount if result.rowcount != -1 else "N/A"
                print(f"Query executed successfully. Row count: {rowcount}")
        except Exception as e:
            print("Error executing query:\n", e)
    print("=" * 60)
    print("\n")


def main():
    queries_file = "queries/queries.sql"  # Path to queries.sql file
    if not os.path.exists(queries_file):
        print(f"ERROR: {queries_file} not found.")
        return

    # -------------------------------------------------
    # 2) Load queries from file
    # -------------------------------------------------
    queries = load_queries_from_file(queries_file)
    if not queries:
        print("No queries found in queries.sql or invalid format.")
        return

    # -------------------------------------------------
    # 3) Run each query in a loop
    # -------------------------------------------------
    for q in queries:
        run_query(q)


if __name__ == "__main__":
    main()
