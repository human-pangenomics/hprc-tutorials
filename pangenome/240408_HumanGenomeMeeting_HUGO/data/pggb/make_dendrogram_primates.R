library(tidyverse)
library(ape)
library(ggtree)

path_dist_tsv <- 'primates14.chr6.fa.gz.667b9b6.c2fac19.ee137be.smooth.final.dist.tsv'

# Read sparse matrix
sparse_matrix_df <- read_tsv(path_dist_tsv)

# Prepare distance matrix
jaccard_dist_df <- sparse_matrix_df %>%
  arrange(group.a, group.b) %>%
  select(group.a, group.b, dice.distance) %>%
  pivot_wider(names_from = group.b, values_from = dice.distance) %>%
  column_to_rownames(var = "group.a")

# Clustering
jaccard_hc <- as.dist(jaccard_dist_df) %>% hclust()

# Open a pdf device with the specified width and height
png(file = "dendrogram.haplotypes.png", width = 500, height = 600)

# Plot the dendrogram
plot(
  jaccard_hc,

  # Label at same height
  hang = -1,
  main = 'primate14.chr6',
  xlab = 'Haplotype',
  ylab = 'Jaccard distance',
  sub = '',
  cex = 1.2
)

# Close the device and save the file
dev.off()