'''
*Program: 01j_compare_translations.py
*Written by: Eric Luong
*Created: 10/07/25
/* Purpose: This code compares the outputs of the data cleaning proceess between Stata and Python.

How to use:
1. Set the working directory to where your Stata and Python output files are located.
2. Set the output variables to the name of the files.
3. The code will read the files, compare them, and export any differences as a CSV file.

Testing Finished: 11/07/25
'''

import pandas as pd
import numpy as np
import os

# Set the working directory and files
path = "/Users/ericluong/Documents/ECON_Research/LN_MJ001/Output/adj_connections"

#Change to Stata and Python output files
output_Stata = 'firstdeg1_v1.csv'
output_Python = 'firstdeg1_v2.csv'

os.chdir(path)
df_Stata = pd.read_csv(output_Stata)
df_Python = pd.read_csv(output_Python)

csv_match = (df_Python.equals(df_Stata))
def checkDiff(csv_match):
    if csv_match:
        print("The Python and STATA csv files are the same.")
    else:
        # Show the differences between the two DataFrames
        diff = pd.concat([df_Python, df_Stata]).drop_duplicates(keep=False)
        print("Rows that differ between Python and STATA outputs:")
        diff.to_csv('differences.csv', index=False)
        return diff

# Check if columns are exactly the same (names and order)
columns_match = (df_Python.columns.equals(df_Stata.columns))
if columns_match:
    print("The Python and STATA Column names and order match.")
    output = checkDiff(csv_match)
else:
    print("The Python and STATA Column names and order do not match.")

    # Columns in Python but not in Stata
    print("Columns in Python but not in Stata:")
    print(set(df_Python.columns) - set(df_Stata.columns))

    # Columns in Stata but not in Python
    print("Columns in Stata but not in Python:")
    print(set(df_Stata.columns) - set(df_Python.columns))
