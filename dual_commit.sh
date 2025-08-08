#!/bin/sh
# This is a post-commit hook script

# Get the remote URL for the current repository
REMOTE_URL=$(git remote get-url origin)

# Extract the service name from the URL
if [[ $REMOTE_URL == *://github.com* ]]; then
    echo "Repository was pushed to GitHub"
elif [[ $REMOTE_URL == *://gitlab.com* ]]; then
    echo "Repository was pushed to GitLab"
elif [[ $REMOTE_URL == *://bitbucket.org* ]]; then
    echo "Repository was pushed to Bitbucket"
elif [[ $REMOTE_URL == *://gitlab* ]]; then
    echo "Repository was pushed to GitLab (custom)"
elif [[ $REMOTE_URL == *://github* ]]; then
    echo "Repository was pushed to GitHub (custom)"
elif [[ $REMOTE_URL == *://git* ]]; then
    echo "Repository was pushed to a custom Git server or local repo"
else
    echo "Unknown repository service or local repository"
fi
