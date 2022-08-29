import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# read .csv
file = "results/app.csv"
df = pd.read_csv(file)
# change column names
df.columns = ["Branch", "Periods", "RRR", "SRRR", "SOFAR"]
# edit values in data column using mapping dictionary
mapping = {
    "set_1": "Regular",
    "set_2": "Covid-19",
    "set_3": "Entire"
}
df["Periods"] = df["Periods"].map(mapping)


# save to latex
latex_name = file.replace(".csv",".tex")
df.to_latex(f"{latex_name}", index=False, float_format="%.4f")