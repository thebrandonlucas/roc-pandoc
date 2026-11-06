# Development environment and tasks for roc-pandoc, realised by Kai without Nix.
#
#     kai run check      # everything the release workflow checks before packaging
#     kai run goldens    # the golden tests alone; add `-- --update` to re-record them
#     kai shell          # the environment, to run scripts/*.roc directly
#     kai update         # refresh .kai/lock.json
#
# `roc-stable` runs repository scripts; `roc` on PATH checks the package, the
# examples and the golden tests on the latest nightly, so nothing here provides
# a bare `roc`. Building, testing and publishing a release is the shared
# roc-automation workflow that .github/workflows/release.yml calls; it runs the
# `check` task here. `pandoc` is expected on PATH for the golden tests and the
# directory examples.
app [kaifile] {
	pf: platform "https://github.com/thebrandonlucas/kai/releases/download/v0.0.12/G3CQ6Ed3h7vyvV4eDvwH1J8UqBv2wEtkb9jLJhFkU5ny.tar.zst",
	std: "https://github.com/thebrandonlucas/kai/releases/download/v0.0.12/std-6VuNBrdv6tT7ZAVD4bWGBYYwk1KJoXP7gCnFip5VSK11.tar.zst",
}

import std.Std

systems = ["x86_64-linux", "aarch64-linux", "aarch64-darwin"]

# A Roc nightly's compiler, for each declared system.
roc_nightly = |tag| {
	nightly = |system, build| {
		top = "roc_nightly-${build}-${tag.drop_prefix("nightly-")}"
		{ system, url: "https://github.com/roc-lang/nightlies/releases/download/${tag}/${top}.tar.gz", mirrors: [], program: Archive("${top}/roc") }
	}
	[nightly("x86_64-linux", "linux_x86_64"), nightly("aarch64-linux", "linux_arm64"), nightly("aarch64-darwin", "macos_apple_silicon")]
}

# A program released as one file per system, named by the system.
file = |url| systems.map(|system| { system, url: "${url}-${system.to_str()}", mirrors: [], program: File })

kaifile = Std.kaifile([
	Name("roc-pandoc"),
	Systems(systems),
	FetchLocked("roc-stable", roc_nightly("nightly-2026-09-10-a670e34")),
	FetchLocked("release-package", file("https://github.com/lukewilliamboswell/roc-automation/releases/download/tools-0.9.0/release-package")),
	# Programs the scripts start.
	Environment("dev", [Tools(["roc-stable#roc-stable"]), Expect(["git", "pandoc", "roc", "unzip"])]),
	# The shared release workflow runs this utility against the `roc` on PATH; a
	# maintainer runs the same task locally, such as `-- test-examples --update`.
	Environment("release", [Tools(["release-package#release-package"]), Expect(["roc", "git", "gh", "pandoc", "tar", "unzip", "zip", "chmod", "touch", "env"])]),
	Shell("default", [Use("dev")]),
	# Everything checked before the release workflow packages anything.
	Task("check", [Use("dev"), Run(["scripts/check_all.roc"])]),
	Task("release-package", [Use("release"), Run(["release-package"])]),
	# The golden tests of tests/cases against tests/goldens.
	Task("goldens", [Use("dev"), Run(["scripts/test_goldens.roc", "--"])]),
	# What a pull request checks, before the release workflow packages anything.
	Workflow("ci", [RunTask("check", []), RunTask("release-package", ["test-examples"])]),
])
