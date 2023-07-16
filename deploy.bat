@echo off

:choice_input
echo Please choose an option:
echo 1. BUILD RELEASE
echo 2. DEPLOY TO FIREBASE
echo 3. PUSH TO GITHUB
echo 4. PERFORM ALL OPTIONS (1-3)
echo 5. CANCEL/EXIT

set /p "choice=Enter your choice: "

if "%choice%"=="1" (
    echo ==================================================
    echo Running flutter build web --release ...
    echo ==================================================
    flutter build web --release
) else if "%choice%"=="2" (
    echo ==================================================
    echo Running firebase deploy ...
    echo ==================================================
    firebase deploy
) else if "%choice%"=="3" (
    set /p "commit_message=Enter commit message: "

    echo ==================================================
    echo Running git add . ...
    echo ==================================================
    git add .

    echo ==================================================
    echo Running git commit -m "%commit_message%" ...
    echo ==================================================
    git commit -m "%commit_message%"

    echo ==================================================
    echo Running git push -u origin main ...
    echo ==================================================
    git push -u origin main
) else if "%choice%"=="4" (
    echo ==================================================
    echo Running flutter build web --release ...
    echo ==================================================
    flutter build web --release

    echo ==================================================
    echo Running firebase deploy ...
    echo ==================================================
    firebase deploy

    set /p "commit_message=Enter commit message: "

    echo ==================================================
    echo Running git add . ...
    echo ==================================================
    git add .

    echo ==================================================
    echo Running git commit -m "%commit_message%" ...
    echo ==================================================
    git commit -m "%commit_message%"

    echo ==================================================
    echo Running git push -u origin main ...
    echo ==================================================
    git push -u origin main
) else if "%choice%"=="5" (
    echo Exiting...
    exit /b
) else (
    echo Invalid choice.
    goto choice_input
)

pause
