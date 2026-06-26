1. Make sure `NEWS.md` is up to date
2. `git pull` from the main branch to make sure you are synced with GitHub
3. Possibly re-pre-compute vignettes by running `vignettes/precompute-vignettes.R`.
4. Make sure `check()` passes.
5. Run `usethis::use_version()` and choose the appropriate version change (major, minor, or patch)
6. It'll ask if you want to commit changes to DESCRIPTION and NEWS.md—say "no"!
7. Run the `update-citation.R` script
8. Commit all the changes with a commit message like "increment package version"
9. Push changes to GitHub
10. Run `usethis::use_github_release()` (or make release on GitHub)
11. Run `usethis::use_dev_version()` and push changes to main.
