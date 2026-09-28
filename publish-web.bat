@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"
echo ==========================================
echo   發布網頁版，讓 iPhone 用 Safari 直接開啟
echo ==========================================
echo.
echo 注意：免費 GitHub 帳號要使用網頁版，儲存庫必須是「公開」。
echo 公開後，任何人都能看到程式碼與網頁。
echo 訂單與歷史紀錄仍只存在各自的瀏覽器，不會上傳。
echo.
set "ANS="
set /p ANS=確定要改成公開並發布網頁版嗎？輸入 Y 再按 Enter：
if /i not "!ANS!"=="Y" (
  echo 已取消。
  pause
  exit /b 0
)

where gh >nul 2>nul
if errorlevel 1 (
  echo 找不到 GitHub CLI，請先執行 setup-github.bat。
  pause
  exit /b 1
)
gh auth status >nul 2>nul
if errorlevel 1 (
  echo 尚未登入 GitHub，請先執行 setup-github.bat。
  pause
  exit /b 1
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

if exist "food-order.html" del "food-order.html"
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

git diff --cached --quiet
if errorlevel 1 (
  if exist ".commit-message.txt" (
    git commit -F ".commit-message.txt"
  ) else (
    git commit -m "新增網頁版"
  )
  if errorlevel 1 (
    echo 建立版本紀錄失敗，請把上面的訊息截圖給協助你的人。
    pause
    exit /b 1
  )
  if exist ".commit-message.txt" del ".commit-message.txt"
  git push
  if errorlevel 1 (
    echo 上傳失敗，請確認網路，或先執行 setup-github.bat。
    pause
    exit /b 1
  )
)

echo.
echo 正在把儲存庫改成公開...
gh repo edit !GHUSER!/food-order-system --visibility public --accept-visibility-change-consequences
if errorlevel 1 (
  echo 改成公開失敗，請把上面的訊息截圖給協助你的人。
  pause
  exit /b 1
)

echo 正在啟用網頁版...
gh api -X POST repos/!GHUSER!/food-order-system/pages -f "source[branch]=main" -f "source[path]=/" >nul 2>nul

set "SITE="
for /f "delims=" %%i in ('gh api repos/!GHUSER!/food-order-system/pages --jq .html_url 2^>nul') do set SITE=%%i
if not defined SITE (
  echo 網頁版啟用失敗，請把上面的訊息截圖給協助你的人。
  pause
  exit /b 1
)

echo.
echo 完成！網頁版網址：
echo !SITE!
echo.
echo 第一次發布需要等 1 到 2 分鐘才會開通。
echo 請在 iPhone 的 Safari 開啟上面的網址，
echo 再點分享按鈕，選「加入主畫面」，之後就像 App 一樣點開使用。
pause
