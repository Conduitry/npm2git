#!/bin/sh

# git ready
set -e
C=; O=; S=; case "$1" in c) C=1 ;; cs) C=1; S=1 ;; o) O=1 ;; os) O=1; S=1 ;; *) echo "Usage: $0 c | cs | o | os
  c = tag release as child of HEAD
  o = tag release as orphan
  s = tag HEAD as vX.X.X-src"; exit 1 ;; esac
cd "$(git rev-parse --show-toplevel)"
ORIG_HEAD="$(git symbolic-ref HEAD)"
ORIG_COMMIT="$(git rev-parse HEAD)"

# extract version from package.json, and remove scripts.prepare
cp package.json package.json.bak
PKG_VERSION="$(node -e '
	const fs = require("fs");
	const str = fs.readFileSync("package.json").toString();
	const m = str.match(/\n([\t ]+)/);
	const indent = m ? m[1] : "\t";
	const pkg = JSON.parse(str);
	pkg.scripts && delete pkg.scripts.prepare;
	fs.writeFileSync("package.json", JSON.stringify(pkg, null, indent) + (str.endsWith("\n") ? "\n" : ""));
	console.log(pkg.version);
')"

# create new temporary branch
TEMP_BRANCH="NPM2GIT-$PKG_VERSION-$(date +%Y%m%d%H%M%S)"
[ $C ] && git checkout -b "$TEMP_BRANCH"
[ $O ] && git checkout --orphan "$TEMP_BRANCH"
git rm --cached -rf .

# commit the files that should be included in the published package
PKG_TAR="$(npm pack | tail -n 1)"
tar tf "$PKG_TAR" | cut -c 9- | xargs -d '\n' git add -f
git commit -nm "v$PKG_VERSION @ $ORIG_COMMIT"

# return to original state
rm "$PKG_TAR"
mv -f package.json.bak package.json
git symbolic-ref HEAD "$ORIG_HEAD"
git reset

# tag commit
[ $S ] && git tag "v$PKG_VERSION-src"
git tag "v$PKG_VERSION" "$TEMP_BRANCH" -am "v$PKG_VERSION @ $ORIG_COMMIT"

# delete temporary branch
git branch -D "$TEMP_BRANCH"
