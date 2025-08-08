# This is a post-commit hook script to dual commit to both github and gitlab
#&commat;echo off

# Get the remote URL for the 'origin' remote
$remoteUrl = git remote get-url origin

# Check if the remote URL is not empty
if ([String]::IsNullOrEmpty($remoteUrl)) {
    Write-Output "Error: No remote URL found for 'origin'."
    exit 1
}

# Check if the GitHub CLI is installed
if exist "C:\Users\%USERNAME%\.local\bin\uv.exe" GOTO :CreateVenv
# If not then install it
winget install --id GitHub.cli
# Check if the GitLab CLI is installed
if exist "C:\Users\%USERNAME%\.local\bin\uv.exe" GOTO :CreateVenv
# If not then install it
winget install glab.glab

# Check the remote URL to determine the service
if ($remoteUrl -like "*://github.com*") {
    Write-Output "Repository was pushed to GitHub"
} elseif ($remoteUrl -like "*://gitlab.com*") {
    Write-Output "Repository was pushed to GitLab"
} elseif ($remoteUrl -like "*://bitbucket.org*") {
    Write-Output "Repository was pushed to Bitbucket"
} elseif ($remoteUrl -like "*://gitlab*") {
    Write-Output "Repository was pushed to GitLab (custom)"
} elseif ($remoteUrl -like "*://github*") {
    Write-Output "Repository was pushed to GitHub (custom)"
} elseif ($remoteUrl -like "*://git*") {
    Write-Output "Repository was pushed to a custom Git server or local repo"
} else {
    Write-Output "Unknown repository service or local repository"
}
