# Systems Biology – Lab Reference (Ritika RP)

M.Sc. Bioinformatics, Manipal School of Life Sciences – Systems Biology lab.
One ready-to-run file per experiment. In every R file, edit **only** the
`CHANGE ONLY THIS` block at the top (file names, cut-offs), then run line by line.

| File | Experiment | What it does |
|---|---|---|
| `00_install_packages.R` | setup | installs every package (+ Ubuntu system libraries) |
| `01_dplyr_variants.R` | Exp 2 – dplyr | high-confidence SNP summary + filter/select/group/mutate/pivot recipes |
| `02_clusterProfiler_enrichment.R` | Exp 3 – clusterProfiler | reads any gene file, auto-detects ID type; GO, groupGO, Reactome, KEGG, Disease (DGN), GSEA + plots |
| `03_limma_microarray.R` | Exp 4 – limma | two-colour Agilent pipeline, DEG counts (up/down), top N, MA/density/volcano plots |
| `04_git_commands.md` | Exp 5 – Git/GitHub | init/commit/branch, fork/clone/push/PR, token, common errors |
| `practice_data/` | practice | genelist.txt, gsea_exercise_genelist.csv, variants.csv, microarray/ (Targets + 4 arrays, simulated) |

## Exam routine
1. Download the given file → put it in one folder.
2. RStudio: **Session → Set Working Directory → Choose Directory**.
3. `list.files()` – the file must be listed.
4. Edit the `CHANGE ONLY THIS` block → run → save plots/tables → write the answer.
