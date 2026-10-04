# =====================================================================
# 03  EXPERIMENT 4 – Two-colour (Agilent) microarray analysis with limma
# =====================================================================
# HOW TO USE IN THE EXAM
#  1. Put Targets file + ALL array files in ONE folder; Session > Set Working Directory.
#  2. Open the targets file and check: column names (FileName, Cy3, Cy5) and
#     the group names written in it (e.g. normal / tumor / control / treated).
#  3. Edit ONLY the block below; run line by line (Ctrl+Enter).
#  If the examiner gives their own script, run theirs up to eBayes(),
#  then use section F/G below for counting, top N and plots.

# ======================= CHANGE ONLY THIS ============================
TARGETS_FILE <- "Targets.txt"     # name of the targets file
SOURCE       <- "agilent"         # "agilent" (median) or "agilent.mean" (mean signal)
REF_GROUP    <- "normal"          # reference/control group EXACTLY as written in Targets
P_CUT        <- 0.05              # p-value cut-off
LFC_CUT      <- 0.5               # |logFC| cut-off (0.5, 1, 2 ...)
USE_ADJ_P    <- FALSE             # TRUE if the question says "adjusted p-value / FDR"
TOP_N        <- 50                # "top N DEGs"
ARRAY_TO_PLOT <- 2                # which array for MA plots
OUT_FILE     <- "outputSelected.txt"
# =====================================================================

library(limma)
list.files()                                   # targets + array files must be listed

# ---------------- A. targets ----------------
targets <- readTargets(TARGETS_FILE)
targets

# ---------------- B. read raw data ----------------
RG <- read.maimages(targets$FileName, source = SOURCE)
dim(RG)                                        # probes x arrays
summary(RG$R)
# record extras:
# y      <- read.maimages(targets, source = "agilent.mean")
# r_only <- read.maimages(targets, source = "agilent.mean",
#                         columns = list(E = "rMeanSignal", Eb = "rBGMedianSignal"))

# ---------------- C. background correction + loess (within-array) ----------------
MA <- normalizeWithinArrays(RG, method = "loess", bc.method = "normexp", offset = 50)
png("MA_before_array.png"); plotMD(RG, column = ARRAY_TO_PLOT, main = "Before normalisation"); dev.off()
png("MA_after_array.png");  plotMD(MA, column = ARRAY_TO_PLOT, main = "After loess");          dev.off()
plotMD(RG, column = ARRAY_TO_PLOT)             # also show in RStudio
plotMD(MA, column = ARRAY_TO_PLOT)
plotMA3by2(MA)                                 # writes MA-1-*.png files into the folder

# ---------------- D. quantile (between-array) ----------------
MA.q <- normalizeBetweenArrays(MA, method = "quantile")
png("density_before_quantile.png"); plotDensities(MA);   dev.off()
png("density_after_quantile.png");  plotDensities(MA.q); dev.off()
plotDensities(MA); plotDensities(MA.q)

# ---------------- E. design + linear model + eBayes ----------------
design <- modelMatrix(targets, ref = REF_GROUP)
design                                         # dye-swapped arrays show -1
fit <- lmFit(MA.q, design)
eb  <- eBayes(fit)
COEF <- 1                                      # column of design to test (usually 1)

# ---------------- F. results + COUNT ----------------
tt <- topTable(eb, coef = COEF, number = Inf, adjust.method = "BH")   # all probes
head(tt)
pcol <- if (USE_ADJ_P) tt$adj.P.Val else tt$P.Value
sig  <- pcol <= P_CUT & abs(tt$logFC) >= LFC_CUT
cat("Significant probes:", sum(sig),
    "| UP:", sum(sig & tt$logFC > 0), "| DOWN:", sum(sig & tt$logFC < 0), "\n")

# record method: export the normalised values of the selected probes
select <- as.numeric(rownames(tt)[sig])
selectedProbes <- MA.q[select, ]
dim(selectedProbes)
write.table(selectedProbes, OUT_FILE, row.names = TRUE, col.names = TRUE, sep = "\t")
write.table(tt[sig, ], "significant_DEGs_table.txt", sep = "\t", quote = FALSE, row.names = FALSE)

summary(decideTests(eb, adjust.method = if (USE_ADJ_P) "BH" else "none",
                    p.value = P_CUT, lfc = LFC_CUT))                # up / down / notsig table

# ---------------- G. TOP N + plots ----------------
topN <- topTable(eb, coef = COEF, number = TOP_N, adjust.method = "BH")
topN[, intersect(c("ProbeName", "GeneName", "logFC", "P.Value", "adj.P.Val"), colnames(topN))]
write.table(topN, paste0("top", TOP_N, "_DEGs.txt"), sep = "\t", quote = FALSE, row.names = FALSE)
cat("Most significant gene:", if (!is.null(topN$GeneName)) topN$GeneName[1] else rownames(topN)[1],
    " logFC =", round(topN$logFC[1], 2), "\n")

png("volcano.png", width = 900, height = 800, res = 120)
volcanoplot(eb, coef = COEF, highlight = 10, names = eb$genes$GeneName, main = "Volcano plot"); dev.off()
volcanoplot(eb, coef = COEF, highlight = 10, names = eb$genes$GeneName)

# heatmap of top N (M-values) - if asked to "visualise / cluster" the top genes
topM <- MA.q$M[as.numeric(rownames(topN)), ]
rownames(topM) <- make.unique(as.character(topN$GeneName))
heatmap(topM, scale = "row", cexRow = 0.5, main = paste("Top", TOP_N, "DEGs"))

# ---------------- TROUBLESHOOTING ----------------
# "cannot open file array1.txt"  -> array files not in the working directory
# modelMatrix error "ref not found" -> REF_GROUP spelled differently in Targets (check case)
# NAs introduced by coercion at as.numeric(rownames) -> rows have probe-name rownames:
#        use  selectedProbes <- MA.q[rownames(tt)[sig], ]  instead
