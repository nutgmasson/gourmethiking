#!/bin/sh

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
git push origin gh-pages

cd ..
