#' Generate list of user info to pass to `flux_download()`
#'
#' A helper to generate a list of AmeriFlux user info to pass along to
#' [flux_download()].  Because these elements are by default pulled from
#' environment variables, it is recommended that you set them in a project-level
#' `.Renviron` file like `AMERIFLUX_USER_NAME=myusername`, etc.
#'
#' @param user_name Your AmeriFlux username.
#' @param user_email The email address associated with your AmeriFlux profile.
#' @param intended_use An integer 1--6 as follows:
#'   \itemize{
#'     \item 1 = Synthesis / network synthesis analysis
#'     \item 2 = Land model/Earth system model
#'     \item 3 = Remote sensing research
#'     \item 4 = Other research
#'     \item 5 = Education (Teacher or Student)
#'     \item 6 = Other
#'   }
#' @param description An optional description of the project.
#' @returns A list with elements `user_name`, `user_email`, `intended_use`, and
#'   `description`.
#' @export
flux_amf_credentials <- function(
  user_name = Sys.getenv("AMERIFLUX_USER_NAME", unset = NA_character_),
  user_email = Sys.getenv("AMERIFLUX_USER_EMAIL", unset = NA_character_),
  intended_use = Sys.getenv("AMERIFLUX_INTENDED_USE", unset = 6),
  description = Sys.getenv("AMERIFLUX_DESCRIPTION", unset = NA_character_)
) {
  if (!intended_use %in% 1:6) {
    cli::cli_abort("{.arg intended_use} must be {.or {1:6}}")
  }
  # TODO: check for valid email
  list(
    user_name = user_name,
    user_email = user_email,
    intended_use = intended_use,
    description = description
  )
}
