import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

file = "day_02/conditions_runs_oxy_project.xlsx"

# load and look at the original Excel sheet
xls = pd.ExcelFile(file)
print(xls.sheet_names)
df = pd.read_excel(file)

# Inspect the data further:
print(df.head(10))
print(df.shape)
print(df.columns.tolist())

# Create a clean DataFrame
#clean_df = df[["Run", "RNA-seq", "DNA-seq"]].copy()
clean_df = df[["Run", "RNA-seq"]].copy()

# Combine condition columns
clean_df["Condition"] = df["condition: Sal"].apply(
    lambda x: "Sal" if x == "x" else "Oxy"
)

# Combine genotype columns
clean_df["Genotype"] = df["Genotype: SNI"].apply(
    lambda x: "SNI" if x == "x" else "Sham"
)

print(clean_df)
print(clean_df["Condition"].value_counts())
print(clean_df["Genotype"].value_counts())
print(pd.crosstab(
    clean_df["Genotype"],
    clean_df["Condition"]
))

# for next task:
base_counts = pd.read_csv("day_02/base_counts.csv")

print(base_counts.head())
print(base_counts.columns.tolist())

# Keep the relevant columns
base_counts = base_counts[["Run", "Bases"]]

# Merge using the SRA run accession
merged_df = clean_df.merge(
    base_counts,
    on="Run",
    how="left",
    validate="one_to_one"
)

print(merged_df)

print(merged_df["Bases"].isna().sum())
merged_df["Bases"] = pd.to_numeric(
    merged_df["Bases"]
)

sorted_df = merged_df.sort_values(
    by=["Condition", "Bases"],
    ascending=[True, True]
)

print(sorted_df.to_string(index=False))

pd.crosstab(
    clean_df["Genotype"],
    clean_df["Condition"]
).plot(
    kind="bar",
    figsize=(6, 4)
)

plt.title("RNA-seq samples by genotype and condition")
plt.xlabel("Genotype")
plt.ylabel("Number of samples")
plt.xticks(rotation=0)
plt.legend(title="Condition")
plt.tight_layout()

# Save the plot
plt.savefig("day_02/sample_distribution.png", dpi=300, bbox_inches="tight")
#plt.show()


smallest_runs = merged_df.nsmallest(2, "Bases")

print(smallest_runs.to_string(index=False))

#safe smallest runs for the nfcore pipeline
smallest_runs["Run"].to_csv(
    "day_02/two_smallest_runs.csv",
    index=False,
    header=False
)

# safe the whole sorted table:
sorted_df.to_csv(
    "day_02/fancy_table.csv",
    index=False
)