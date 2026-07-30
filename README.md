# asdf-spinel

Spinel plugin for [asdf](https://asdf-vm.com).

Spinel currently has no versioned GitHub releases or tags, so this plugin
installs the `master` source from [`matz/spinel`](https://github.com/matz/spinel).

## Install

```sh
asdf plugin add spinel https://github.com/jockofcode/asdf-spinel.git
asdf install spinel master
asdf set -u spinel master
```

## Updating

Because asdf skips the install step when a version is already present, updating
to the newest `master` requires an uninstall first:

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
- `tar`
- `make`
- a C compiler available as `cc`

## Configuration

To install from a fork, set `SPINEL_GITHUB_REPO`:

```sh
SPINEL_GITHUB_REPO=your-user/spinel asdf install spinel master
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
