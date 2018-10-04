# bail on failures
set -e

# go to root of repository
cd $(git rev-parse --show-toplevel)

# get commit id
COMMIT_ID="$(git rev-parse HEAD)"

# extract package name and version from package.json, remove scripts.prepare
ORIG_PKG="$(cat package.json)"
read NAME VERSION < <(node -e '
	const fs = require("fs");
	const pkg = JSON.parse(fs.readFileSync("package.json"));
	if (pkg.scripts && pkg.scripts.prepare) {
		delete pkg.scripts.prepare;
		fs.writeFileSync("package.json", JSON.stringify(pkg, null, "\t") + "\n");
	}
	console.log(pkg.name + " " + pkg.version);
')

# determine current branch name, and create new temporary branch
ORIG_BRANCH=$(git symbolic-ref --short HEAD)
TEMP_BRANCH=RELEASE_${VERSION}_$(date +'%Y%m%d%H%M%S')
git add .
git checkout --orphan=${TEMP_BRANCH}

# untrack all files, and track the files that should be included in the published package
git rm --cached -r .
npm pack
git add -f $(tar tf ${NAME}-${VERSION}.tgz | cut -c 9-)
rm ${NAME}-${VERSION}.tgz

# commit and tag
git commit -m "v${VERSION} @ ${COMMIT_ID}"
git tag v${VERSION} -a -m "v${VERSION} @ ${COMMIT_ID}"

# return to original state
git reset ${ORIG_BRANCH}
git checkout ${ORIG_BRANCH}
cat <<< "${ORIG_PKG}" > package.json
git branch -D ${TEMP_BRANCH}
