# npm2git

Use Git as an npm registry

## Why

Managing npm registries sucks. (And arguably, depending on a central privately-controlled npm registry also sucks.) If you're thinking you want or need to run one, then you almost certainly already have a Git server available with all the appropriate users and permissions and everything. npm supports resolving semver ranges against Git tags, so there's no longer a good reason not to abuse Git to deliver built assets.

## How

This shell script creates and tags an orphaned commit that includes only the files that would be included by `npm publish`. Before doing so, it also removes the `prepare` script from `package.json`, if present. When npm installs from a Git repository with a `prepare` script, it will also temporarily install `devDependencies` and run the `prepare` script, which generally would build the project. What they're getting is already the built files, so we don't want that to happen.

## Usage

1. Make sure you're ready to go. The `version` field in your `package.json` should already be incremented, and the `files` field should point to everything you want to publish.
1. Run `npm2git.sh`. This creates the orphaned commit and tags it `vX.X.X`, but does not push it. Inspect the tag to make sure all seems well.
1. Push the tag.

## Installing from Git

See [the npm docs on `npm install`](https://docs.npmjs.com/cli/install) for more on how to install from Git repositories. Specify a version either by tag (`#vX.X.X`) or by semver specification (`#semver:*`).

## License

Copyright (c) 2018 Conduitry

- [MIT](LICENSE)
