# =====================================================================
# 02  EXPERIMENT 3 – clusterProfiler: GO / groupGO / Reactome / KEGG /
#     Disease (DGN) / GSEA  for a GIVEN gene file
# =====================================================================
# HOW TO USE IN THE EXAM
#  1. Put the given file(s) in one folder; Session > Set Working Directory.
#  2. OPEN the gene file first (Files pane > click it) and look:
#       - one gene per line, or a table with columns?
#       - is there a header line?
#       - IDs look like  CDK1 (SYMBOL)  /  983 (ENTREZ)  /  ENSG00000170312 (ENSEMBL)?
#  3. Edit ONLY the block below. Run sections A + B always, then only the
#     section the question asks for (C, D, E, F, G or H).

# ======================= CHANGE ONLY THIS ============================
GENE_FILE   <- "genelist.txt"   # gene list file (.txt or .csv)
HAS_HEADER  <- FALSE            # TRUE if the first line is a column name (e.g. "gene")
GENE_COLUMN <- 1                # which column has the genes (number or "name")
ONT         <- "BP"             # "BP", "CC", "MF" or "ALL"
P_CUT       <- 0.05             # p-value cut-off asked in the question
TOP_N       <- 10               # how many terms to show in plots ("top 5" -> 5)
GO_LEVEL    <- 3                # level for groupGO
# --- only for GSEA (ranked list with logFC) ---
GSEA_FILE   <- "gsea_exercise_genelist.csv"
GSEA_GENE_COL <- "gene_symbol"  # column with gene names
GSEA_LFC_COL  <- "logFC"        # column with fold change
# --- only if the question uses the built-in DOSE example instead of a file ---
USE_DOSE_EXAMPLE <- FALSE
# =====================================================================

# ---------------- A. load packages ----------------
library(clusterProfiler); library(org.Hs.eg.db); library(enrichplot)
library(ggplot2); library(dplyr)

# ---------------- B. read genes + convert IDs ----------------
if (USE_DOSE_EXAMPLE) {
  data(geneList, package = "DOSE")
  genes <- names(geneList)[abs(geneList) > 2]          # Entrez IDs
} else {
  sep <- if (grepl("\\.csv$", GENE_FILE)) "," else ""   # "" = any whitespace/tab
  tab <- read.table(GENE_FILE, header = HAS_HEADER, sep = sep,
                    stringsAsFactors = FALSE, quote = "\"", fill = TRUE)
  genes <- unique(trimws(as.character(tab[[GENE_COLUMN]])))
  genes <- genes[genes != "" & !is.na(genes)]
}
length(genes); head(genes)

# detect ID type automatically
ID_TYPE <- if (all(grepl("^[0-9]+$", genes))) "ENTREZID" else
           if (all(grepl("^ENSG", genes)))    "ENSEMBL"  else "SYMBOL"
ID_TYPE
if (ID_TYPE == "ENTREZID") {
  gene_entrez <- genes
} else {
  ids <- bitr(genes, fromType = ID_TYPE, toType = "ENTREZID", OrgDb = org.Hs.eg.db)
  gene_entrez <- unique(ids$ENTREZID)
}
length(gene_entrez)        # a few lost in conversion is normal (warning is OK)

# helper: answer + save for any result
report <- function(res, name) {
  df <- as.data.frame(res)
  cat("\n==", name, "==  significant terms:", nrow(df), "\n")
  if (nrow(df) == 0) { cat("No significant terms - try P_CUT <- 0.1 or another ontology\n"); return(invisible(df)) }
  print(head(df[, intersect(c("ONTOLOGY", "Description", "GeneRatio", "Count", "p.adjust", "NES"), colnames(df))], TOP_N))
  cat("MOST SIGNIFICANT:", df$Description[which.min(df$p.adjust)], "\n")
  write.csv(df, paste0(name, "_results.csv"), row.names = FALSE)
  invisible(df)
}

# ---------------- C. GO ENRICHMENT (enrichGO)  ** most common ** ----------------
ego <- enrichGO(gene = gene_entrez, OrgDb = org.Hs.eg.db, keyType = "ENTREZID",
                ont = ONT, pAdjustMethod = "BH", pvalueCutoff = P_CUT,
                qvalueCutoff = 0.2, readable = TRUE)
report(ego, paste0("GO_", ONT))
p <- barplot(ego, showCategory = TOP_N) + ggtitle(paste("GO", ONT, "enrichment"))
print(p); ggsave(paste0("GO_", ONT, "_barplot.png"), p, width = 9, height = 6, dpi = 300)
p <- dotplot(ego, showCategory = TOP_N) + ggtitle(paste("GO", ONT, "enrichment"))
print(p); ggsave(paste0("GO_", ONT, "_dotplot.png"), p, width = 9, height = 6, dpi = 300)
# other enrichplot plots (if asked):
cnetplot(ego, showCategory = 5)                        # gene-term network
heatplot(ego, showCategory = 10)                       # genes x terms
emapplot(pairwise_termsim(ego), showCategory = 20)     # term similarity map
upsetplot(ego)

# ---------------- D. GO CLASSIFICATION (groupGO) ----------------
GG_ONT <- ifelse(ONT == "ALL", "BP", ONT)              # groupGO needs BP/CC/MF
ggo <- groupGO(gene = gene_entrez, OrgDb = org.Hs.eg.db, ont = GG_ONT,
               level = GO_LEVEL, readable = TRUE)
ggo_df <- as.data.frame(ggo) %>% filter(Count > 0) %>% arrange(desc(Count))
head(ggo_df[, c("Description", "Count")], TOP_N)
p <- barplot(ggo, showCategory = TOP_N) + ggtitle(paste("GO classification", GG_ONT, "level", GO_LEVEL))
print(p); ggsave(paste0("groupGO_", GG_ONT, "_barplot.png"), p, width = 9, height = 6, dpi = 300)

# ---------------- E. REACTOME PATHWAYS ----------------
library(ReactomePA)
rp <- enrichPathway(gene = gene_entrez, organism = "human", pAdjustMethod = "BH",
                    pvalueCutoff = P_CUT, readable = TRUE)
report(rp, "Reactome")
p <- barplot(rp, showCategory = TOP_N) + ggtitle("Reactome pathway enrichment")
print(p); ggsave("Reactome_barplot.png", p, width = 9, height = 6, dpi = 300)

# ---------------- F. KEGG PATHWAYS (needs internet) ----------------
kk <- enrichKEGG(gene = gene_entrez, organism = "hsa", pvalueCutoff = P_CUT)
report(kk, "KEGG")
p <- barplot(kk, showCategory = TOP_N) + ggtitle("KEGG pathway enrichment")
print(p); ggsave("KEGG_barplot.png", p, width = 9, height = 6, dpi = 300)

# ---------------- G. DISEASE ENRICHMENT (DisGeNET = "Disease Gene Network") ----------------
library(DOSE)
dgn <- enrichDGN(gene = gene_entrez, pvalueCutoff = P_CUT, readable = TRUE)
report(dgn, "DGN")
p <- barplot(dgn, showCategory = TOP_N) + ggtitle("Disease Gene Network enrichment")
print(p); ggsave("DGN_barplot.png", p, width = 9, height = 6, dpi = 300)
# Disease Ontology instead:  edo <- enrichDO(gene_entrez, pvalueCutoff = P_CUT)

# ---------------- H. GSEA (ranked list with logFC) ----------------
gsea_tab <- read.csv(GSEA_FILE, header = TRUE)
head(gsea_tab)                                         # check the column names!
gsea_list <- gsea_tab[[GSEA_LFC_COL]]
names(gsea_list) <- gsea_tab[[GSEA_GENE_COL]]
gsea_list <- na.omit(gsea_list)
gsea_list <- gsea_list[!duplicated(names(gsea_list))]
set.seed(42)
gsea_list <- gsea_list + rnorm(length(gsea_list), 0, 1e-10)   # break exact ties
gsea_list <- sort(gsea_list, decreasing = TRUE)               # MUST be decreasing
GSEA_KEY <- if (all(grepl("^[0-9]+$", names(gsea_list)))) "ENTREZID" else
            if (all(grepl("^ENSG", names(gsea_list))))   "ENSEMBL"  else "SYMBOL"
gsea_res <- gseGO(geneList = gsea_list, OrgDb = org.Hs.eg.db, keyType = GSEA_KEY,
                  ont = ifelse(ONT == "ALL", "BP", ONT), pvalueCutoff = P_CUT,
                  nPermSimple = 10000, verbose = FALSE)
gdf <- report(gsea_res, "GSEA")
cat("Activated (NES > 0):", sum(gdf$NES > 0), "  Suppressed (NES < 0):", sum(gdf$NES < 0), "\n")
p <- dotplot(gsea_res, showCategory = TOP_N, split = ".sign") + facet_wrap(~.sign, scales = "free")
print(p); ggsave("GSEA_dotplot.png", p, width = 10, height = 7, dpi = 300)
p <- ridgeplot(gsea_res, showCategory = TOP_N)
print(p); ggsave("GSEA_ridgeplot.png", p, width = 10, height = 7, dpi = 300)
gseaplot2(gsea_res, geneSetID = 1, title = gdf$Description[1])

# ---------------- TROUBLESHOOTING ----------------
# "cannot open file"            -> wrong folder: Session > Set Working Directory
# "--> No gene can be mapped"   -> wrong ID_TYPE / wrong column / header line read as a gene
# 0 significant terms           -> raise P_CUT (0.1) or try another ontology; say so in answer
# KEGG error / timeout          -> no internet: use Reactome (section E) instead
# ridgeplot error               -> install.packages("ggridges")
