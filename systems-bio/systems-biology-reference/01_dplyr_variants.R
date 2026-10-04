# =====================================================================
# 01  EXPERIMENT 2 – dplyr on variant (VCF table) data
# =====================================================================
# HOW TO USE IN THE EXAM
#  1. Put the given file in one folder.
#  2. RStudio: Session > Set Working Directory > Choose Directory -> that folder
#  3. Edit ONLY the block below, then run the file line by line (Ctrl+Enter).

# ======================= CHANGE ONLY THIS ============================
INPUT_FILE <- "combined_tidy_vcf.csv"   # file name EXACTLY as given (case matters!)
DOWNLOAD   <- FALSE                     # TRUE = download the lab file from the internet
QUAL_MIN   <- 200                       # quality cut-off asked in the question
DP_MIN     <- 10                        # read-depth cut-off asked in the question
SAMPLE     <- "SRR2584863"              # sample asked about (for single-sample questions)
OUT_FILE   <- "high_confidence_summary.csv"
# =====================================================================

library(dplyr); library(tidyr); library(readr); library(ggplot2)

if (DOWNLOAD) {
  download.file("https://raw.githubusercontent.com/datacarpentry/genomics-r-intro/main/episodes/data/combined_tidy_vcf.csv",
                destfile = INPUT_FILE)
}
list.files()                       # the file name must appear here
# read_csv for .csv ; read_tsv for tab-separated .txt/.tsv
variants <- if (grepl("\\.csv$", INPUT_FILE)) read_csv(INPUT_FILE) else read_tsv(INPUT_FILE)

# ---- Look at the data first ----------------------------------------
glimpse(variants)                  # columns + types
dim(variants)                      # rows, columns
colnames(variants)                 # if column names differ from below, change them in the code
variants %>% count(sample_id)      # variants per sample

# =====================================================================
# MAIN QUESTION (sir's question): which sample has the most
# high-confidence SNPs?  Criteria: no INDELs, QUAL >= QUAL_MIN, DP >= DP_MIN
# =====================================================================
high_confidence_summary <- variants %>%
  filter(INDEL == FALSE,           # SNPs only (same as !INDEL)
         QUAL >= QUAL_MIN,
         DP   >= DP_MIN) %>%
  group_by(sample_id) %>%
  summarize(n_variants = n(),
            mean_QUAL  = mean(QUAL, na.rm = TRUE),
            mean_DP    = mean(DP,   na.rm = TRUE)) %>%
  arrange(desc(n_variants))        # largest first -> row 1 is the answer
high_confidence_summary
cat("Sample with most high-confidence SNPs:", high_confidence_summary$sample_id[1],
    "(", high_confidence_summary$n_variants[1], "variants )\n")
write_csv(high_confidence_summary, OUT_FILE)
# Write on the answer sheet: "INDELs were excluded and only variants with
# QUAL >= 200 and DP >= 10 were kept. <sample> has the most (<n>)."

# =====================================================================
# RECIPES – copy the one the question asks for
# =====================================================================
# select = COLUMNS
select(variants, sample_id, REF, ALT, DP)
select(variants, -CHROM)                       # all except CHROM
select(variants, ends_with("B"))               # names ending in B
select(variants, starts_with("Q"), contains("DP"))

# filter = ROWS     ( , or & = AND    | = OR    ! = NOT    %in% = one of )
filter(variants, sample_id == SAMPLE, DP > 20)
filter(variants, REF %in% c("T", "G"))
filter(variants, INDEL)                        # only INDELs
filter(variants, !is.na(IDV))                  # IDV not missing
filter(variants, sample_id == SAMPLE, (MQ >= 50 | QUAL >= 100))
filter(variants, POS >= 1e6, POS <= 2e6, !INDEL, QUAL > 200)

# "How many ...?"  -> add  %>% nrow()   or use count()
variants %>% filter(sample_id == SAMPLE, QUAL >= 100) %>% nrow()
variants %>% count(sample_id, INDEL)           # SNPs vs INDELs per sample
variants %>% filter(INDEL) %>% count(sample_id, sort = TRUE)   # most INDELs

# summary per group
variants %>% group_by(sample_id) %>%
  summarize(mean_DP = mean(DP, na.rm = TRUE), max_QUAL = max(QUAL, na.rm = TRUE),
            min_QUAL = min(QUAL, na.rm = TRUE), count = n())

# sort / top N
variants %>% arrange(desc(QUAL)) %>% select(sample_id, POS, REF, ALT, QUAL) %>% head(5)

# new column
variants %>% mutate(QUAL_normalized = QUAL / 100) %>% select(sample_id, POS, QUAL, QUAL_normalized)
variants %>% mutate(DP_category = ifelse(DP >= DP_MIN, "high", "low")) %>% count(sample_id, DP_category)

# slice = rows by position
variants %>% filter(sample_id == SAMPLE) %>% slice(1:6)

# reshape
long <- variants %>% select(sample_id, POS, QUAL, DP) %>%
  pivot_longer(cols = c(QUAL, DP), names_to = "measurement_type", values_to = "measurement_value")
wide <- long %>% pivot_wider(names_from = measurement_type, values_from = measurement_value)

# plot (if asked)
p <- variants %>% count(sample_id) %>%
  ggplot(aes(x = sample_id, y = n, fill = sample_id)) + geom_col() +
  labs(title = "Variants per sample", x = "Sample", y = "Number of variants") + theme_minimal()
print(p); ggsave("variants_per_sample.png", p, width = 7, height = 5, dpi = 300)

# save any table:  write_csv(<table>, "name.csv")
