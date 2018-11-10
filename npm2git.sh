#!/bin/sh

# git ready
set -e
cd "$(git rev-parse --show-toplevel)"
ORIG_HEAD="$(git symbolic-ref HEAD)"
ORIG_COMMIT="$(git rev-parse HEAD)"

# extract version from package.json, and remove scripts.prepare
cp package.json package.json.bak
PKG_VERSION="$(node -e '
	const fs = require("fs");
	const pkg = JSON.parse(fs.readFileSync("package.json"));
	pkg.scripts && delete pkg.scripts.prepare;
	fs.writeFileSync("package.json", JSON.stringify(pkg));
	console.log(pkg.version);
')"

# create new temporary branch
TEMP_BRANCH="NPM2GIT-$PKG_VERSION-$(date +%Y%m%d%H%M%S)"
git checkout --orphan="$TEMP_BRANCH"
git rm --cached -rf .

# commit the files that should be included in the published package
PKG_TAR="$(npm pack | tail -n 1)"
tar tf "$PKG_TAR" | cut -c 9- | xargs -d '\n' git add -f
git commit -m "v$PKG_VERSION @ $ORIG_COMMIT"

# return to original state
rm "$PKG_TAR"
mv -f package.json.bak package.json
git symbolic-ref HEAD "$ORIG_HEAD"
git reset

# tag commit
git tag "v$PKG_VERSION-src" -am "v$PKG_VERSION-src"
git tag "v$PKG_VERSION" "$TEMP_BRANCH" -am "v$PKG_VERSION @ $ORIG_COMMIT"

# delete temporary branch
git branch -D "$TEMP_BRANCH"
