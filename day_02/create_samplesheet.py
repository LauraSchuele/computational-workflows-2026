import pandas as pd
from pathlib import Path

# Location of our FASTQ files
fastq_dir = Path("day_02/fetchngs_out/fastq").resolve()

# Information from our cleaned metadata
samples = pd.DataFrame({
    "Run": ["SRR23195516", "SRR23195511"],
    "Experiment": ["SRX19144486", "SRX19144488"],
    "Condition": ["Oxy", "Oxy"],
    "Genotype": ["SNI", "Sham"]
})

# Create informative sample names
samples["sample"] = (
    samples["Genotype"] + "_" +
    samples["Condition"] + "_" +
    samples["Run"]
)

# Construct the FASTQ file paths
samples["fastq_1"] = samples.apply(
    lambda row: str(
        fastq_dir / f"{row['Experiment']}_{row['Run']}_1.fastq.gz"
    ),
    axis=1
)

samples["fastq_2"] = samples.apply(
    lambda row: str(
        fastq_dir / f"{row['Experiment']}_{row['Run']}_2.fastq.gz"
    ),
    axis=1
)

samples["strandedness"] = "auto"
samples["seq_platform"] = "ILLUMINA"

samplesheet = samples[
    [
        "sample",
        "fastq_1",
        "fastq_2",
        "strandedness",
        "seq_platform"
    ]
]

# Verify that the FASTQ files exist
for column in ["fastq_1", "fastq_2"]:
    for path in samplesheet[column]:
        assert Path(path).is_file(), f"Missing file: {path}"

samplesheet.to_csv(
    "day_02/rnaseq_samplesheet.csv",
    index=False
)

print(samplesheet.to_string(index=False))


