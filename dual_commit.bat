:: Check to see if GitLab CLI is installed or not
if exist "C:\Users\%USERNAME%\.local\bin\uv.exe" GOTO :Login
:: If not then install it
winget install glab.glab
:Login
:: Check for token in .env file
if GOTO :ManualSetup
    token = Get-Content .env | Select-String -Pattern "GITLAB_TOKEN" | ForEach-Object { $_.ToString().Split('=')[1] }
:: Use token for login
    glab auth login -u token
GOTO :CheckGitLab
:ManualSetup
:: Login via CLI
glab auth login
:: Get a token for future use
:: command ["gitlab-rails","runner",User.admins.last.personal_access_tokens.create(name: 'apitoken', token_digest: Gitlab::CryptoHelper.sha256('#{token}'), impersonation: true, scopes: [:api])"]
:CheckGitLab
:: Check if the GitLab project exists
for /f "tokens=*" %%a in ('gitlab-project --name "%REPO_NAME%" --url "%GITLAB_URL%"') do (
    if "%%a" == "exists" (
        echo GitLab project "%REPO_NAME%" exists.
    ) else (
        echo GitLab project "%REPO_NAME%" does not exist. Creating it...
        gitlab-create-project --name "%REPO_NAME%" --url "%GITLAB_URL%"
        curl = Invoke-RestMethod -Uri "https://gitlab.com/api/v4/projects" `
            -Method POST `
            -Headers @{"PRIVATE-TOKEN" = $token} `
            -Body @{
                "name" = $projectName
                "namespace_id" = "123456"  # Replace with your namespace ID
                "visibility_level" = "private"
            } | ConvertTo-Json
    )
)
:: Get the current commit message
for /f "tokens=*" %%i in ('git log -1 --pretty=%H% %d% %s%') do (
    set "COMMIT_MESSAGE=%%i"
)
:: Push the commit to GitLab
echo Pushing commit with message: "%COMMIT_MESSAGE%"
git push origin main --set-upstream
git push origin main --force-with-lease
git push origin main --set-upstream



projectName = (Get-Content .env | Select-String -Pattern "REPO_NAME" | ForEach-Object { $_.ToString().Split('=')[1] })

curl = Invoke-RestMethod -Uri "https://gitlab.com/api/v4/projects" `
    -Method POST `
    -Headers @{"PRIVATE-TOKEN" = $token} `
    -Body @{
        "name" = $projectName
        "namespace_id" = "123456"  # Replace with your namespace ID
        "visibility_level" = "private"
    } | ConvertTo-Json

echo "GitLab project created: $projectName"


@echo off
setlocal

:: Set variables
set "REPO_NAME=your-repo-name"
set "GITLAB_TOKEN="
set "GITLAB_URL=https://gitlab.com"
set "GITHUB_URL=https://github.com/your-username/your-repo-name.git"
set "LOCAL_REPO_PATH=C:\path\to\local\repo"
set "ENV_FILE=.env"

:: Check if .env file exists
if not exist "%ENV_FILE%" (
    echo .env file not found. Creating one...
    echo GITLAB_URL=%GITLAB_URL% > "%ENV_FILE%"
    echo GITLAB_TOKEN=%GITLAB_TOKEN% >> "%ENV_FILE%"
    echo GITHUB_URL=%GITHUB_URL% >> "%ENV_FILE%"
    echo LOCAL_REPO_PATH=%LOCAL_REPO_PATH% >> "%ENV_FILE%"
    echo REPO_NAME=%REPO_NAME% >> "%ENV_FILE%"
) else (
    for /f "tokens=2 delims==" %%i in (%ENV_FILE%) do (
        set "GITLAB_URL=%%i"
    )
    for /f "tokens=2 delims==" %%i in (%ENV_FILE%) do (
        set "GITLAB_TOKEN=%%i"
    )
    for /f "tokens=2 delims==" %%i in (%ENV_FILE%) do (
        set "GITHUB_URL=%%i"
    )
    for /f "tokens=2 delims==" %%i in (%ENV_FILE%) do (
        set "LOCAL_REPO_PATH=%%i"
    )
    for /f "tokens=2 delims==" %%i in (%ENV_FILE%) do (
        set "REPO_NAME=%%i"
    )
)

:: Check if the local repo exists
if not exist "%LOCAL_REPO_PATH%" (
    echo Local repository not found. Cloning from GitHub...
    git clone "%GITHUB_URL%" "%LOCAL_REPO_PATH%"
) else (
    echo Local repository found.
)

:: Check if the GitLab project exists
for /f "tokens=*" %%a in ('gitlab-project --name "%REPO_NAME%" --url "%GITLAB_URL%"') do (
    if "%%a" == "exists" (
        echo GitLab project "%REPO_NAME%" exists.
    ) else (
        echo GitLab project "%REPO_NAME%" does not exist. Creating it...
        gitlab-create-project --name "%REPO_NAME%" --url "%GITLAB_URL%"
    )
)

:: Login to GitLab using the token
if defined GITLAB_TOKEN (
    echo Logging in to GitLab using token...
    gitlab login -u %GITLAB_TOKEN%
) else (
    echo No GitLab token found in .env. Please provide one.
    exit 1
)

:: Get the current commit message
for /f "tokens=*" %%i in ('git log -1 --pretty=%H% %d% %s%') do (
    set "COMMIT_MESSAGE=%%i"
)

:: Push the commit to GitLab
echo Pushing commit with message: "%COMMIT_MESSAGE%"
git push origin main --set-upstream
git push origin main --force-with-lease
git push origin main --set-upstream
