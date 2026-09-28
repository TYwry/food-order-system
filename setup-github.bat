@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"
echo ==========================================
echo   第一次上傳到 GitHub（只需要執行一次）
echo ==========================================
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo 找不到 Git，正在用 winget 安裝...
  winget install --id Git.Git -e --source winget
  echo.
  echo 安裝完成。請「關閉這個視窗」後，再雙擊 setup-github.bat 一次。
  pause
  exit /b 0
)

where gh >nul 2>nul
if errorlevel 1 (
  echo 找不到 GitHub CLI，正在用 winget 安裝...
  winget install --id GitHub.cli -e --source winget
  echo.
  echo 安裝完成。請「關閉這個視窗」後，再雙擊 setup-github.bat 一次。
  pause
  exit /b 0
)

gh auth status >nul 2>nul
if errorlevel 1 (
  echo 需要登入 GitHub，接下來會開啟瀏覽器，請依畫面指示輸入驗證碼。
  gh auth login --web
  if errorlevel 1 (
    echo 登入失敗，請重新執行。
    pause
    exit /b 1
  )
)
gh auth setup-git

if not exist ".git" (
  git init -b main
)

for /f "delims=" %%i in ('gh api user --jq .login') do set GHUSER=%%i
for /f "delims=" %%i in ('gh api user --jq .id') do set GHID=%%i
if not defined GHUSER (
  echo 無法取得 GitHub 帳號名稱，請重新執行。
  pause
  exit /b 1
)
git config user.name >nul 2>nul
if errorlevel 1 git config user.name "!GHUSER!"
git config user.email >nul 2>nul
if errorlevel 1 git config user.email "!GHID!+!GHUSER!@users.noreply.github.com"

powershell -NoProfile -Command "$p='README.md'; $t=[IO.File]::ReadAllText($p); $t=$t.Replace('__GH_USER__','!GHUSER!'); [IO.File]::WriteAllText($p,$t,(New-Object Text.UTF8Encoding($false)))"

git add -A
git diff --cached --name-only | findstr /i /r "config\.json history\.json \.env \.log \.key \.pem \.pfx secret password credential apikey api_key" >nul
if not errorlevel 1 (
  echo.
  echo [安全檢查未通過] 發現可能含有金鑰或個人資料的檔案，已取消上傳：
  git diff --cached --name-only | findstr /i /r "config\.json history\.json \.env \.log \.key \.pem \.pfx secret password credential apikey api_key"
  git reset >nul 2>nul
  pause
  exit /b 1
)

if exist ".commit-message.txt" (
  git commit -F ".commit-message.txt"
) else (
  git commit -m "初始版本"
)
if errorlevel 1 (
  echo 建立版本紀錄失敗，請把上面的訊息截圖給協助你的人。
  pause
  exit /b 1
)
if exist ".commit-message.txt" del ".commit-message.txt"

echo.
echo 正在建立 GitHub 儲存庫（不公開）並上傳...
gh repo create food-order-system --private --source . --push
if errorlevel 1 (
  echo 上傳失敗，請把上面的訊息截圖給協助你的人。
  pause
  exit /b 1
)

echo.
echo 完成！之後修改檔案，只要雙擊 save.bat 就能存檔上傳。
echo 想在 iPhone 用 Safari 直接開啟網頁版，請再雙擊 publish-web.bat。
pause
