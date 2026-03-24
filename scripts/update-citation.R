library(cffr)
cff <- cff_create(
  dependencies = FALSE
)

fs::file_delete("inst/CITATION")
cff_write(cff)
cff_write_citation(cff, file = "inst/CITATION")
