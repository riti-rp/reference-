# =====================================================================
# 00  INSTALL ALL PACKAGES  (run ONCE per computer, needs internet)
# =====================================================================
# On Ubuntu, FIRST run this in the Terminal (Ctrl+Alt+T), otherwise
# Bioconductor packages fail to compile:
#
#   sudo apt update
#   sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev \
#     libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev \
#     libpng-dev libjpeg-dev
#
# Then run this file in RStudio (Ctrl+Shift+Enter runs the whole file).
# If asked "Would you like to use a personal library instead?" -> type yes
# If asked "Update all/some/none?" -> type n  (or none)

# ---- CRAN packages (Experiments 1, 2) --------------------------------
install.packages(c("dplyr", "tidyr", "ggplot2", "readr", "stringr",
                   "BiocManager", "ggridges", "pheatmap"))

# ---- Bioconductor packages (Experiments 3, 4) ------------------------
BiocManager::install(c("limma",            # Exp 4 microarray
                       "clusterProfiler",  # Exp 3 enrichment
                       "org.Hs.eg.db",     # human gene annotation
                       "enrichplot",       # dotplot, cnetplot, ridgeplot ...
                       "DOSE",             # example geneList + disease enrichment
                       "ReactomePA"),      # Reactome pathways
                     update = FALSE, ask = FALSE)

# ---- Check: every line must print TRUE --------------------------------
pkgs <- c("dplyr", "tidyr", "ggplot2", "readr", "limma", "clusterProfiler",
          "org.Hs.eg.db", "enrichplot", "DOSE", "ReactomePA", "ggridges")
sapply(pkgs, requireNamespace, quietly = TRUE)
# If one is FALSE, install it alone and READ the error:
#   BiocManager::install("clusterProfiler")
# An error naming "libxml-2.0", "curl", "openssl", "fontconfig" etc. means
# the matching -dev package from the apt line above is missing.
