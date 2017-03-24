#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)


#source("https://bioconductor.org/biocLite.R")
#biocLite("oligo")

#source("https://bioconductor.org/biocLite.R")
#biocLite("pd.hg.u133.plus.2")

#source("https://bioconductor.org/biocLite.R")
#biocLite("pd.hugene.1.0.st.v1")



library(oligo)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "tmp"
}
print(paste("args:", args[1], args[2], args[3]))

celFile <- read.celfiles(args[1])
fname = sampleNames(celFile)
png(filename=paste(args[2],"/",args[3], '.png', sep=''), width=5000, height=5000)
image(celFile[,1], col=gray((64:0)/64))
dev.off()

