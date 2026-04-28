# Generate list of user info to pass to `flux_download()`

A helper to generate a list of AmeriFlux user info to pass along to
[`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md).
Because these elements are by default pulled from environment variables,
it is recommended that you set them in a project-level `.Renviron` file
like `AMERIFLUX_USER_NAME=myusername`, etc.

## Usage

``` r
flux_amf_credentials(
  user_name = Sys.getenv("AMERIFLUX_USER_NAME", unset = NA_character_),
  user_email = Sys.getenv("AMERIFLUX_USER_EMAIL", unset = NA_character_),
  intended_use = Sys.getenv("AMERIFLUX_INTENDED_USE", unset = 6),
  description = Sys.getenv("AMERIFLUX_DESCRIPTION", unset = NA_character_)
)
```

## Arguments

- user_name:

  Your AmeriFlux username.

- user_email:

  The email address associated with your AmeriFlux profile.

- intended_use:

  An integer 1–6 as follows:

  - 1 = Synthesis / network synthesis analysis

  - 2 = Land model/Earth system model

  - 3 = Remote sensing research

  - 4 = Other research

  - 5 = Education (Teacher or Student)

  - 6 = Other

- description:

  An optional description of the project.

## Value

A list with elements `user_name`, `user_email`, `intended_use`, and
`description`.
