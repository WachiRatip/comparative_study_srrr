import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# read .csv
file = "results/paperresults.csv"
df = pd.read_csv(file)

# drop row named RRR in framework column 
df = df.drop(df[df["framework"] == "RRR"].index)

# split dataframe into two dataframes, one for each target
df_target1 = df[df["target"] == "CO"]
df_target2 = df[df["target"] == "COCI"]
# drop framework and target column
df_target1 = df_target1.drop(columns=["framework", "target"])
df_target2 = df_target2.drop(columns=["framework", "target"])

# print those dataframes
print(df_target1)
print(df_target2)

# merge dataframes into one dataframe by merging on branch column
df_all = pd.merge(df_target1, df_target2, on="branch")
# add dquare value of regular_x to regular_y to new column Regular and drop regular_x and regular_y
df_all["Regular"] = df_all["regular_x"]**2 + df_all["regular_y"]**2
df_all = df_all.drop(columns=["regular_x", "regular_y"])
# add covid_x to covid_y to new column Covid19 and drop covid_x and covid_y
df_all["Covid19"] = df_all["covid19_x"]**2 + df_all["covid19_y"]**2
df_all = df_all.drop(columns=["covid19_x", "covid19_y"])
# add entire_x to entire_y to new column Entire and drop entire_x and entire_y
df_all["Entire"] = df_all["entrie_x"]**2 + df_all["entrie_y"]**2
df_all = df_all.drop(columns=["entrie_x", "entrie_y"])

# print merged dataframe
print(df_all)

# save to latex
latex_name = file.replace(".csv",".tex")
df_all.to_latex(f"{latex_name}", index=False, float_format="%.4f")