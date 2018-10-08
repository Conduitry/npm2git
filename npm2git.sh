# bail on failures
set -e

# go to root of repository
cd "$(git rev-parse --show-toplevel)"

# get commit id
ORIG_COMMIT="$(git rev-parse HEAD)"

# extract version from package.json, and remove scripts.prepare
ORIG_PKG="$(cat package.json)"
PKG_VERSION="$(node -e '
	const fs = require("fs");
	const pkg = JSON.parse(fs.readFileSync("package.json"));
	if (pkg.scripts && pkg.scripts.prepare) {
		delete pkg.scripts.prepare;
		fs.writeFileSync("package.json", JSON.stringify(pkg, null, "\t") + "\n");
	}
	console.log(pkg.version);
')"

# determine current branch name, and create new temporary branch
ORIG_BRANCH="$(git symbolic-ref --short HEAD)"
TEMP_BRANCH="RELEASE_${PKG_VERSION}_$(date +'%Y%m%d%H%M%S')"
git checkout --orphan="${TEMP_BRANCH}"
git rm --cached -rf .

# track the files that should be included in the published package
PKG_TAR="$(npm pack | tail -n 1)"
tar tf "${PKG_TAR}" | cut -c 9- | xargs -d '\n' git add -f
rm "${PKG_TAR}"

# commit and tag
git commit -m "v${PKG_VERSION} @ ${ORIG_COMMIT}"
git tag "v${PKG_VERSION}" -am "v${PKG_VERSION} @ ${ORIG_COMMIT}"

# return to original state
git reset "${ORIG_BRANCH}"
git checkout "${ORIG_BRANCH}"
cat <<< "${ORIG_PKG}" > package.json
git branch -D "${TEMP_BRANCH}"
