library(cffr)
cff <- cff_create(
  dependencies = FALSE
)

cff_write(cff)
cff_write_citation(cff, file = "inst/CITATION")
