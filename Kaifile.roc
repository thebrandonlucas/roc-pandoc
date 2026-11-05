# Development environment and tasks for roc-pandoc, realised by Kai without Nix.
#
#     kai run check      # everything the release workflow checks before packaging
#     kai run goldens    # the golden tests alone; add `-- --update` to re-record them
#     kai shell          # the environment, to run scripts/*.roc directly
#     kai update         # refresh .kai/lock.json
#
# `roc-stable` runs repository scripts; `roc` on PATH checks the package, the
# examples and the golden tests on the latest nightly, so nothing here provides
# a bare `roc`. Building, testing and publishing a release is
# .github/workflows/release-package.yml, which release.yml calls; it runs the
# `check` and `release-package` tasks here. `pandoc` is expected on PATH for
# the golden tests and the directory examples.
app [kaifile] {
	pf: platform "https://github.com/thebrandonlucas/kai/releases/download/v0.0.11/65bk6qdahqxn1mm6LR6Hkyw8dSdoeRZGwjNSuiPfvguP.tar.zst",
	std: "https://github.com/thebrandonlucas/kai/releases/download/v0.0.11/std-6Jw5GxNCFkpnvBbnFmQg4KAVEn5bAfEveSZfDSzTDs42.tar.zst",
}

import std.Std

# A Roc nightly's compiler, for each system this project declares.
roc_nightly = |tag| {
	date = tag.drop_prefix("nightly-")
	one = |system, build| {
		top = "roc_nightly-${build}-${date}"
		{
			system,
			url: "https://github.com/roc-lang/nightlies/releases/download/${tag}/${top}.tar.gz",
			mirrors: [],
			program: Archive("${top}/roc"),
		}
	}
	[one("x86_64-linux", "linux_x86_64"), one("aarch64-linux", "linux_arm64"), one("aarch64-darwin", "macos_apple_silicon")]
}

# A released file for each system this project declares, named by the system.
per_system = |prefix| {
	one = |system, suffix| { system, url: "${prefix}${suffix}", mirrors: [], program: File }
	[one("x86_64-linux", "x86_64-linux"), one("aarch64-linux", "aarch64-linux"), one("aarch64-darwin", "aarch64-darwin")]
}

kaifile = Std.kaifile([
	Name("roc-pandoc"),
	Systems(["x86_64-linux", "aarch64-linux", "aarch64-darwin"]),
	FetchLocked("roc-stable", roc_nightly("nightly-2026-09-10-a670e34")),
	FetchLocked("release-package", per_system("https://github.com/lukewilliamboswell/roc-automation/releases/download/tools-0.9.0/release-package-")),
	Environment("dev", [Tools(["roc-stable#roc-stable"]), Expect(["git", "pandoc", "roc", "unzip"])]),
	Environment("release", [Tools(["release-package#release-package"]), Expect(["roc", "git", "gh", "pandoc", "tar", "unzip", "zip", "chmod", "touch", "env"])]),
	Shell("default", [Use("dev")]),
	Task("check", [Use("dev"), Run(["scripts/check_all.roc"])]),
	Task("release-package", [Use("release"), Run(["release-package"])]),
	Task("goldens", [Use("dev"), Run(["scripts/test_goldens.roc", "--"])]),
])
