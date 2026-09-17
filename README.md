# asdf-spinel

Spinel plugin for [asdf](https://asdf-vm.com).

This plugin installs tagged releases straight from
[`matz/spinel`](https://github.com/matz/spinel)'s GitHub releases, or the
`master` branch if you want the latest unreleased commit. The list of
installable release versions is fetched live from the GitHub API each time,
so the plugin never needs to be updated just because a new Spinel version
shipped.

## Install

```sh
asdf plugin add spinel https://github.com/jockofcode/asdf-spinel.git
asdf list all spinel
asdf install spinel latest
asdf set -u spinel latest
```

Or install a specific release:

```sh
asdf install spinel 2026.09.12
asdf set -u spinel 2026.09.12
```

Or track the `master` branch:

```sh
asdf install spinel master
asdf set -u spinel master
```

Installing a tagged release resolves and pins the exact commit that tag
points to at install time, so the install stays reproducible even if the tag
is later moved upstream.

## Updating

Because asdf skips the install step when a version is already present,
updating `master` (or re-pulling a moved tag) requires an uninstall first:

```sh
asdf uninstall spinel master
asdf install spinel master
asdf set -u spinel master
```

## What Gets Installed

The plugin downloads the Spinel source archive, runs `make deps`, then runs:

```sh
make install PREFIX="$ASDF_INSTALL_PATH"
```

The Spinel install target creates shims for:

- `spinel`
- `spin`
- `spinel-doctor`
- `spinel-reduce`
- `spinel-flatten`

## Dependencies

- `bash`
- `curl`
- `jq`
- `tar`
- `make`
- a C compiler available as `cc`

## Configuration

To install from a fork, set `SPINEL_GITHUB_REPO`:

```sh
SPINEL_GITHUB_REPO=your-user/spinel asdf install spinel master
```

Listing and resolving releases calls the GitHub API unauthenticated, which is
rate-limited per IP. If you hit rate limits (e.g. in CI), set
`GITHUB_API_TOKEN` (or `GH_TOKEN`) to a GitHub token to raise the limit:

```sh
GITHUB_API_TOKEN=ghp_xxx asdf install spinel latest
```

To install an arbitrary Git ref, use asdf's ref install form:

```sh
asdf install spinel ref:COMMIT_OR_BRANCH
```

## Development

Run the lightweight checks:

```sh
./scripts/check
```

Try the plugin locally:

```sh
asdf plugin add spinel "$PWD"
asdf list all spinel
asdf install spinel master
```

## License

[MIT](LICENSE)
