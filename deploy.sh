#!/bin/sh
EXPECTED_HUGO_VERSION="v0.113"

echo "Checking hugo version..."
hugo version | grep $EXPECTED_HUGO_VERSION
hugo_version_ret_code=$?

if [ $hugo_version_ret_code != 0 ]; then
    echo "You have the wrong version of hugo installed."
    echo "Current version"
    hugo version
    echo "Expected version: $EXPECTED_HUGO_VERSION"
    exit $hugo_version_ret_code
fi

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public origin/gh-pages

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo
hugo_ret_code=$?

if [ $hugo_ret_code != 0 ]; then
	echo "Stopping deployment... Can't generate the static website."
	exit $hugo_ret_code
fi

cd public

echo "Adding CNAME configuration"
echo gourmethiking.com >> CNAME

echo "Updating gh-pages branch"
git add --all && git commit -m "Publishing to gh-pages (deploy.sh)"

echo "Fetching remote branches"
git fetch

echo "Pushing changes to gh-pages"
git push -f origin gh-pages

cd ..
