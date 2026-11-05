# Contributing to roc-pandoc

Use issues for bugs and design discussion, and pull requests for changes.
Install Pandoc and unzip, then [Kai](https://github.com/thebrandonlucas/kai) 0.0.11 or later, which runs
on Linux, and a current Roc nightly on `PATH` as `roc`. Kai locks the independent repository tooling
compiler in `.kai/lock.json`.

```sh
kai check
kai run check
kai run goldens -- --update
kai run release-package -- test-examples
```

Review golden-output changes before accepting them. Generate both public
modules’ API reference with `roc docs package/main.roc`; add `--serve` to browse it.

## Write documentation

Write for a current user or contributor task. Delete superseded or duplicated
material and follow the [shared documentation guidance](https://lukewilliamboswell.github.io/roc-automation/documentation.html#write-project-documentation).
Implementation history belongs in Git, pending work in issues and release
changes in the release record.
