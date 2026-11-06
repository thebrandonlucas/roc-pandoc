# Contributing to roc-pandoc

Use issues for bugs and design discussion, and pull requests for changes.
Install Pandoc and unzip, then the Kai release named at the top of `Kaifile.roc` and a current Roc nightly
on `PATH` as `roc`. Kai locks the independent repository tooling compiler in `.kai/lock.json`.

```sh
kai check
kai run check
kai run goldens -- --update
kai run release-package -- test-examples
kai workflow ci   # check, then the examples, as a pull request does
```

Review golden-output changes before accepting them. Generate both public
modules’ API reference with `roc docs package/main.roc`; add `--serve` to browse it.

## Write documentation

Write for a current user or contributor task. Delete superseded or duplicated
material and follow the [shared documentation guidance](https://lukewilliamboswell.github.io/roc-automation/documentation.html#write-project-documentation).
Implementation history belongs in Git, pending work in issues and release
changes in the release record.
