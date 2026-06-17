library(cffr)
fs::file_delete("inst/CITATION")
cff <- cff_create(
  dependencies = FALSE,
  keys = list(
    # This DOI always re-directs to the most recent version on Zenodo
    doi = "10.5281/zenodo.19210221",
    `date-released` = Sys.Date()
  )
)

# Write inst/CITATION
con <- file("inst/CITATION", open = "wt")
writeLines(
  "cli::cli_alert_warning('In addition to citing this package, please cite all data used. See {.fun fluxnet::flux_citations}')",
  con = con
)
close(con)
cff_write_citation(cff, file = "inst/CITATION", append = TRUE)


# Write CITATION.cff
cff_write(cff)
