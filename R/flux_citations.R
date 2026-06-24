#' Output required per-dataset citations for FLUXNET data
#'
#' Given a vector of site IDs, this either returns a dataframe with or BibTeX
#' citations for each site.
#'
#' @param site_ids Character vector of site IDs, e.g. `c("AR-Bal", "DE-Gwg")`.
#' @param output Either `"data.frame"` to return a tibble or `"bibtex"` to
#'   return (or write) BibTeX entries. See '**Value**' for more details.
#' @param bibtex_path Path to a .bib file to write BibTeX to, passed to the
#'   `con` argument of [writeLines()]. If `NULL` (default), BibTeX will be
#'   returned as character. Has no effect if `output = 'data.frame'`.
#' @param ... Additional arguments passed to [flux_listall()].
#'
#' @returns If `output = 'data.frame'`, a `tibble` is returned with a
#'   `bibentry` list-column with elements of class [bibentry] and a `citation`
#'   column with citations formatted in the default style (see the `format()`
#'   method for [bibentry()] for more details).  If `output = 'bibtex'`, BibTeX
#'   entries are either returned as an atomic character vector (if `bibtex_path`
#'   is `NULL`) or written to a file.
#' @examples
#' # Return dataframe with bibentries and formatted citations
#' flux_citations(c("AR-Bal", "DE-Gwg"))
#'
#' # Return BibTeX
#' flux_citations(c("AR-Bal", "DE-Gwg"), output = "bibtex")
#'
#' # Append BibTeX entries to a file
#' \dontrun{
#' flux_citations(
#'   c("AR-Bal", "DE-Gwg"),
#'   output = "bibtex",
#'   bibtex_path = "references.bib"
#' )
#' }
#'
#' @export
flux_citations <- function(
  site_ids,
  output = c("data.frame", "bibtex"),
  bibtex_path = NULL,
  ...
) {
  list <- flux_listall(...)
  site_citations_raw <- list %>%
    dplyr::filter(.data$site_id %in% site_ids) %>%
    dplyr::select(dplyr::all_of(c(
      "site_id",
      "site_name",
      "data_hub",
      "product_citation",
      "product_id",
      "oneflux_code_version"
    )))

  by_hub <- split(
    site_citations_raw,
    site_citations_raw$data_hub
  )

  if (!is.null(by_hub$AmeriFlux)) {
    amf_pattern <- "^(.+)\\((\\d{4})\\), (.+), Ver\\. .+, (.+), \\(Dataset\\)\\. (.+)$"
    amf_split <- stringr::str_match(
      by_hub$AmeriFlux$product_citation,
      pattern = amf_pattern
    )
    colnames(amf_split) <- c(
      "product_citation",
      "authors",
      "year",
      "title",
      "publisher",
      "url"
    )
    amf_split <- dplyr::as_tibble(amf_split)

    amf <- dplyr::left_join(
      by_hub$AmeriFlux,
      amf_split,
      by = "product_citation"
    ) %>%
      dplyr::mutate(doi = .data$product_id)
  } else {
    amf <- dplyr::tibble()
  }

  if (!is.null(by_hub$ICOS)) {
    # For ICOS, sometimes there is no author
    icos_pattern <- "^(.+)?\\s?\\((\\d{4})\\)\\. (.+), FLUXNET, (https.+)$"
    icos_split <- stringr::str_match(
      by_hub$ICOS$product_citation,
      pattern = icos_pattern
    )
    colnames(icos_split) <- c(
      "product_citation",
      "authors",
      "year",
      "title",
      "url"
    )
    icos_split <- dplyr::as_tibble(icos_split)
    icos <- dplyr::left_join(
      by_hub$ICOS,
      icos_split,
      by = "product_citation"
    ) %>%
      dplyr::mutate(
        publisher = "Ecosystem Thematic Centre",
        pid = .data$product_id
      )
  } else {
    icos <- dplyr::tibble()
  }

  if (!is.null(by_hub$TERN)) {
    tern_pattern <- "^(.+)\\((\\d{4})\\): (.+\\.).?Version.+"
    tern_split <- stringr::str_match(
      by_hub$TERN$product_citation,
      pattern = tern_pattern
    )
    colnames(tern_split) <- c("product_citation", "authors", "year", "title")
    tern_split <- dplyr::as_tibble(tern_split)
    tern <- dplyr::left_join(
      by_hub$TERN,
      tern_split,
      by = "product_citation"
    ) %>%
      dplyr::mutate(
        publisher = "Terrestrial Ecosystem Research Network (TERN)",
        url = .data$product_id,
        doi = stringr::str_remove(.data$product_id, "https:\\/\\/dx.doi.org\\/")
      )
  } else {
    tern <- dplyr::tibble()
  }
  combined <- dplyr::bind_rows(amf, icos, tern) %>%
    dplyr::mutate(type = "dataset") %>%
    dplyr::select(-dplyr::all_of("product_citation"))

  bibentries <- combined %>%
    tidyr::nest(.by = c("site_id", "site_name", "product_id")) %>%
    dplyr::mutate(
      bibentry = purrr::map(.data$data, function(x) {
        utils::bibentry(
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
    dplyr::select(-dplyr::all_of("data"))

  # Add cite keys
  # TODO: make these Zotero/BetterBibTex style with a piece of the title in them
  # to make them more likely to be unique
  bibentries$bibentry <- bibentries$bibentry %>%
    purrr::map(function(x) {
      first_author_family <- tolower(x$author[[1]]$family)
      if (is.null(first_author_family)) {
        first_author_family <- "noauthor"
      }
      x$key <- paste(first_author_family, x$year, sep = "_")
      x
    })

  output <- match.arg(output)
  if (output == "data.frame") {
    bibentries %>% dplyr::mutate(citation = purrr::map_chr(.data$bibentry, format))
  } else if (output == "bibtex") {
    bibtex_list <- purrr::map_chr(bibentries$bibentry, function(x) {
      format(x, style = "bibtex")
    })
    bibtex_text <- paste0(bibtex_list, collapse = "\n")
    if (is.null(bibtex_path)) {
      cat(bibtex_text) # print with nice formatting
      return(invisible(bibtex_text)) # return character atomic vector
    } else {
      writeLines(bibtex_text, bibtex_path)
    }
  }
}

