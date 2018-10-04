# bail on failures
set -e

# go to root of repository
cd $(git rev-parse --show-toplevel)

# extract package name and version from package.json
NAME=$(node -e 'console.log(require("./package.json").name)')
VERSION=$(node -e 'console.log(require("./package.json").version)')

# remove devDependencies and scripts.prepare
ORIG_PKG="$(cat package.json)"
node -e '
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json"));
delete pkg.devDependencies;
if (pkg.scripts) {
	delete pkg.scripts.prepare;
}
fs.writeFileSync("package.json", JSON.stringify(pkg, null, "\t") + "\n");
'

# determine current branch name, and create new temporary branch
ORIG_BRANCH=$(git symbolic-ref --short HEAD)
TEMP_BRANCH=RELEASE_${VERSION}_$(date +'%Y%m%d%H%M%S')
git checkout -b ${TEMP_BRANCH}

# untrack all files, and track the files that should be included in the published package
git rm --cached -r .
npm pack
git add -f $(tar tf ${NAME}-${VERSION}.tgz | cut -c 9-)
rm ${NAME}-${VERSION}.tgz

# commit, tag, push
git commit -m "Release v${VERSION}"
git tag v${VERSION} -a -m "v${VERSION}"
git push origin v${VERSION}

# return to original state
git reset ${ORIG_BRANCH}
git checkout ${ORIG_BRANCH}
echo "${ORIG_PKG}" > package.json
git branch -D ${TEMP_BRANCH}
