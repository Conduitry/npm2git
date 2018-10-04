# npm2git

 Use Git as an npm registry

## Why

Managing npm registries sucks. If you're thinking about running one, then you almost certainly already have a Git server available with all the appropriate users and permissions and everything. npm supports resolving semver ranges against Git tags, so there's no longer a good reason to not abuse Git to deliver built assets.

## How

This creates and tags an orphaned commit that includes only the files that would be included in `npm publish`. In the tagged commit, it also removes the `prepare` script from `package.json` if present - the assumption being that this would build the project if someone were installing from your source files, and what we're tagging is already the built files.

## Usage

1. Make sure you're ready to go. The `version` field in your `package.json` should be already incremented, and the `files` field should point to everything you want to publish.
1. Run `npm2git.sh`. This creates the orphaned commit and tags it `vX.X.X`, but does not push it. Inspect the tag to make sure all seems well.
1. Push the tag.

## Installing from Git

See [the npm docs on `npm install`](https://docs.npmjs.com/cli/install) for more on how to install from Git repositories. Specify a version either by tag (`#vX.X.X`) or by semver specification (`#semver:^X.X.X`).

## License

Copyright (c) 2018 Conduitry

- [MIT](LICENSE)
