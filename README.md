# npm2git

Use Git as an npm registry.

## Why

Managing an npm registry sucks, and using a central, privately controlled registry also arguably sucks. If you're thinking you want or need to run one, then it's reasonably likely that you already have a Git server available with all the appropriate users and permissions and everything. npm v5+ supports resolving semver ranges against Git tags, so there's no longer a good reason not to abuse Git to deliver built assets.

## How

This shell script creates and tags a (possibly orphaned) commit which includes only the files that would be included by `npm publish`. Before doing so, it also removes the `prepare` script from `package.json`, if present. (The `prepare` script is typically used to build a package after installing it from Git. Here, what npm's getting is already the built files, so we don't want that to happen.) It also optionally creates a (non-annotated) `vX.X.X-src` tag which points to the original source that the (annotated) `vX.X.X` tag was built from.

## Usage

1. Make sure you're ready to go: Your project should be built, the `version` field in your `package.json` should already be incremented, and the `files` field should point to everything you want to publish.
1. Run `npm2git.sh` with the appropriate option for how you want the commit and tag(s) created. This does not push anything.
	- `c` - Tag release as a child commit of `HEAD`.
	- `cs` - Same, but also tag `HEAD` as `vX.X.X-src`.
	- `o` - Tag release as an orphaned commit.
	- `os` - Same, but also tag `HEAD` as `vX.X.X-src`.
1. Inspect to make sure all seems well, and then push.

## Nom

See [the npm docs on `npm install`](https://docs.npmjs.com/cli/install) for more on how to install from Git repositories. Specify a version either by tag (`#vX.X.X`) or by semver specification (`#semver:*`).

## License

[MIT](LICENSE)
