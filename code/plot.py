import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

files = []
path = "./results/"
file_extension = "ChenHuangFullrankLowdimRhostructures.csv"
file_extension_alternative = "ChenHuangFullrankLowdimFGNstructures.csv"
for file in os.listdir(path=path):
    if file.endswith(file_extension) or file.endswith(file_extension_alternative):
        print(file)
        files.append(file)
    else:
        continue

for idx,file in enumerate(files):
    name = file.split("-")
    if file.endswith(file_extension):
        errorType = "AR"
        SigmaX = f"AR({name[5]})"
        SigmaE = f"AR({name[6]})"
    if file.endswith(file_extension_alternative):
        errorType = "FGN"
        SigmaX = f"AR({name[5]})"
        SigmaE = f"FGN({name[6]})"


    df = pd.read_csv(path+file)
    # add column for error type
    df["errorType"] = errorType
    # add column for rhoX
    df["SigmaX"] = SigmaX
    # add column for rhoE
    df["SigmaE"] = SigmaE

    if (idx == 0):
        df_all = df
    else:
        df_all = df_all.append(df)  
    del df

    print(df_all)

# plot df_all as a categorical plot of model and avgMSE
plt = sns.catplot(x="model", y="MSE", hue="SigmaE",  col="SigmaX", kind="bar", data=df_all)
# save figure
plt.savefig(f"{path}plot.png", bbox_inches="tight")
