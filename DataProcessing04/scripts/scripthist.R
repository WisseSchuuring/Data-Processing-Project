

my_data <- read.csv(file=snakemake@input[[1]], header=FALSE, sep=',')
jpeg(snakemake@output[[1]])

d <- as.matrix(my_data[-1,-1])

heatmap(d)

dev.off()

