'''
*Program: 01d_adjacency_matrix.py
*Written by: Eric Luong
*Created: 09/07/25
*Last updated: TBD
/* Purpose: Translating 01d_create_testing_timeseries.do to Python. This portion of the code was written to clean up the time series data to be used for the adjacency matrix.
'''

import pandas as pd
import numpy as np
import os

# Set the working directory
origin = "/Users/ericluong/Documents/ECON_Research/LN_MJ001/Data"
destination = "/Users/ericluong/Documents/ECON_Research/LN_MJ001/Output/01d"
input_data = 'testing_timeseries.csv'

os.chdir(origin)
df = pd.read_csv(input_data)

print("***************************************************************")
# "Need to fix this" First part of code that filters users with exactly 111 entries
def part1(df):
    user_counts = df['user_id'].value_counts()
    kept_users = user_counts[user_counts == 111].index
    df_filtered = df[df['user_id'].isin(kept_users)]
    return df_filtered

def part2(df):
    df = df.rename(columns={'user_id': 'user_id_old', 'user_id_new': 'user_id'})
    df['index'] = df['user_id']
    kept_columns = ['index', 'user_id', 'user_id_old', 'time', 'TS_company', 'year', 'month']
    df = df[kept_columns]
    df['monthyear'] = df['year'].astype(str) + df['month'].astype(str).str.zfill(2)    
    df = df.drop(columns = ['year', 'month'])
    df = df.rename(columns={'TS_company': 'company'})
    #egen user_id_new = group(user_id) //
    df['user_id_new'] = pd.factorize(df['user_id'])[0] + 1  # Factorize user_id to create a unique integer ID
    return df

# Preserve data/cleaned ID mapping (Will tackle this later) 
# def part3(df):
#     df = df.rename(columns={'user_id': 'user_id_old', 'user_id_new': 'user_id'})
#     cols = ['index', 'user_id', 'user_id_old' 'time', 'company', 'monthyear']
#     df = df[cols]
#     return df

def part4(df, size):
    df = df.drop(columns=['user_id', 'user_id_old'])
    df = df.rename(columns={'user_id_new': 'user_id'})
    cols = ['index', 'user_id', 'monthyear', 'company', 'time']
    df = df[cols]
    df['index'] = df['user_id']  # Potentially redundant, but keeping for consistency
    
    # May change with bigger dataset
    df_size = df['user_id'] <= size
    df = df[df_size]

    # Replace company names with standardized names
    df.loc[df['company'].str.contains('novartis', case=False, na=False), 'company'] = 'novartis'
    df.loc[df['company'].str.contains('theravance', case=False, na=False), 'company'] = 'theravance'
    df.loc[df['company'].str.contains('ucsf', case=False, na=False), 'company'] = 'ucsf'
    
    return df

df = part1(df)
df = part2(df)
# df_UserID = part3(df)
df_Python = part4(df,50)

print(df_Python.head()) # Preview
print(len(df_Python))  # Number of rows

# Export the cleaned DataFrame to a CSV file
os.chdir(destination)
#df_UserID.to_csv('userid_match_python.csv', index=False)
df_Python.to_csv('testing_timeseries_forADJ_python_50sample.csv', index=False)