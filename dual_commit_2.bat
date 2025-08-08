:: Define variables
set "CURRENT_DIR=%CD%"
set "ENV_FILE=%CURRENT_DIR%\..\..\myenv.env"
set "GITLAB_TOKEN="

:: Check if .env file exists
if not exist "%ENV_FILE%" (
    echo .env file not found at: %ENV_FILE%
    exit /b 1
)

:: Read the .env file and extract the GITLAB_TOKEN
for /f "tokens=2 delims==" %%i in (%ENV_FILE%) do (
    set "GITLAB_TOKEN=%%i"
)


::UNICORN_POD=$(kubectl get pods -n gitlab-system -l=app=unicorn -o jsonpath='{.items[0].metadata.name}')
::kubectl exec -n gitlab-system -it $UNICORN_POD -c unicorn -- /bin/bash -c '
::cd /srv/gitlab;
::bin/rails r "
::token_digest = Gitlab::CryptoHelper.sha256 \"1234567890\";
::token=PersonalAccessToken.create!(name: \"Full Access\", scopes: [:api], user: User.where(id: 1).first, token_digest: token_digest);
::token.save!
::";
::'
