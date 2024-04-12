install.packages('BiocManager')

pkgs = c('tidyverse',
         'remotes',
         'ape')

ap.db <- available.packages(contrib.url(BiocManager::repositories()))
ap <- rownames(ap.db)

pkgs_to_install <- pkgs[pkgs %in% ap]

BiocManager::install(pkgs_to_install, update=FALSE, ask=FALSE)

remotes::install_github('YuLab-SMU/ggtree')

# just in case there were warnings, we want to see them
# without having to scroll up:
warnings()

if (!is.null(warnings()))
{
    w <- capture.output(warnings())
    if (length(grep("is not available|had non-zero exit status", w)))
        quit("no", 1L)
}

## suppressWarnings(BiocManager::install(update=TRUE, ask=FALSE))
