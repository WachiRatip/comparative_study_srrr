import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

filename = "RothmanChenHuangFullrankHighdim"

def get_df(filename, filetype):
    files = []
    path = "./results/"
    file_extension = f"{filename}Rhostructures{filetype}.csv"
    file_extension_alternative = f"{filename}FGNstructures{filetype}.csv"
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
            SigmaX = f"AR({name[-3]})"
            SigmaE = f"AR({name[-2]})"
        if file.endswith(file_extension_alternative):
            errorType = "FGN"
            SigmaX = f"AR({name[-3]})"
            SigmaE = f"FGN({name[-2]})"


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

    # drop errorType column
    df_all = df_all.drop(columns=["errorType"])

    # reorder rows by AR(0) and AR(0.5)
    df_all = df_all.sort_values(by=["SigmaX", "SigmaE"])
    return df_all

df_1 = get_df(filename, "MEAN")
df_2 = get_df(filename, "SD")

# merge dataframes into one dataframe by merging on SigmaX, SigmaE, model columns
df_all = pd.merge(df_1, df_2, on=["SigmaX", "SigmaE", "model"])
df_all = df_all[["SigmaX", "SigmaE", "model", "avgMSE", "sdMSE", "avgSPEC", "sdSPEC", "avgSENS", "sdSENS"]]
print(df_all)

# save to latex
latex_name = f"{filename}.tex"
df_all.to_latex(f"{latex_name}", index=False, float_format="%.4f")