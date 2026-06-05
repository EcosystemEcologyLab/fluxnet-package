flux_citations <- function(
  site_ids,
  output = c("table", "bibtex"),
  output_path = NULL,
  ...
) {
  list <- flux_listall(...)
  site_citations_raw <- list %>%
    filter(site_id %in% site_ids) %>%
    select(
      site_id,
      site_name,
      data_hub,
      product_citation,
      product_id,
      oneflux_code_version
    )

  by_hub <- split(
    site_citations_raw,
    site_citations_raw$data_hub
  )
  amf_pattern <- "^(.+)\\((\\d{4})\\), (.+) Ver\\. .+, (.+), \\(Dataset\\)\\. (.+)$"
  amf_split <- stringr::str_match(
    by_hub$AmeriFlux$product_citation,
    pattern = amf_pattern
  ) %>%
    as_tibble()
  colnames(amf_split) <- c(
    "product_citation",
    "authors",
    "year",
    "title",
    "publisher",
    "url"
  )

  amf <- left_join(
    by_hub$AmeriFlux,
    amf_split,
    by = join_by(product_citation)
  ) %>%
    mutate(doi = product_id)

  # For ICOS, sometimes there is no author
  icos_pattern <- "^(.+)?\\s?\\((\\d{4})\\)\\. (.+), FLUXNET, (https.+)$"
  icos_split <- stringr::str_match(
    by_hub$ICOS$product_citation,
    pattern = icos_pattern
  ) %>%
    as_tibble()
  colnames(icos_split) <- c(
    "product_citation",
    "authors",
    "year",
    "title",
    "url"
  )
  icos <- left_join(by_hub$ICOS, icos_split, by = join_by(product_citation)) %>%
    mutate(
      publisher = "Ecosystem Thematic Centre",
      pid = product_id
    )

  tern_pattern <- "^(.+)\\((\\d{4})\\): (.+\\.).?Version.+"
  tern_split <- stringr::str_match(
    by_hub$TERN$product_citation,
    pattern = tern_pattern
  ) %>%
    as_tibble()
  colnames(tern_split) <- c("product_citation", "authors", "year", "title")
  tern <- left_join(by_hub$TERN, tern_split, by = join_by(product_citation)) %>%
    mutate(
      publisher = "Terrestrial Ecosystem Research Network (TERN)",
      url = product_id,
      doi = stringr::str_remove(product_id, "https:\\/\\/dx.doi.org\\/")
    )

  bibentries <- bind_rows(amf, icos, tern) %>%
    mutate(type = "dataset") %>%
    select(-product_citation) %>%
    nest(.by = c(site_id, site_name, product_id)) %>%
    mutate(
      bibentry = map(data, \(x) {
        bibentry(
          "misc",
          author = x$authors,
          title = x$title,
          year = x$year,
          publisher = x$publisher,
          doi = x$doi,
          pid = x$pid,
          url = x$url,
          type = "dataset"
        )
      })
    ) %>%
    select(-data)
}

