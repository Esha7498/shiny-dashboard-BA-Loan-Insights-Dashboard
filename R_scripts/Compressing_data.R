# Load and save compressed
sba_clean <- readRDS("data/sba_cleaned.rds")
saveRDS(sba_clean, "data/sba_cleaned_compressed.rds", compress = "xz")

# Check new size
file.info("data/sba_cleaned_compressed.rds")$size / 1024^2

