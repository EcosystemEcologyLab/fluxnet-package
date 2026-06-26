# https://ropensci.org/blog/2019/12/08/precompute-vignettes/
knitr::knit("vignettes/fluxnet.Rmd.source", output = "vignettes/fluxnet.Rmd")
knitr::knit(
  "vignettes/fluxnet-duckdb.Rmd.source",
  output = "vignettes/fluxnet-duckdb.Rmd"
)
# move figures
fs::dir_copy("figure", "vignettes/figure", overwrite = TRUE)
fs::dir_delete("figure")
