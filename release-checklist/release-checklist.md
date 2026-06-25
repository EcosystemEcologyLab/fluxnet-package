1. Make sure `NEWS.md` is up to date
2. Possibly re-pre-compute vignettes by running `vignettes/precompute-vignettes.R`.
3. `git pull` and `git push` from the main branch to make sure you are synced with GitHub
4. Run `usethis::use_version()` and choose the appropriate version change (major, minor, or patch)
5. It'll ask if you want to commit changes to DESCRIPTION and NEWS.md—say "no"!
6. Run the `update-citation.R` script
7. Commit all the changes with a commit message like "increment package version"
8. Push changes to GitHub
9. Run `usethis::use_github_release()` (or make release on GitHub)
10. Run `usethis::use_dev_version()` and push changes to main.
