@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

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
if not errorlevel 1 (
  echo 沒有需要上傳的變更。
  pause
  exit /b 0
)

if exist ".commit-message.txt" (
  git commit -F ".commit-message.txt"
) else (
  set "MSG="
  set /p MSG=請輸入這次修改的說明（直接按 Enter 會用「更新」）：
  if not defined MSG set "MSG=更新"
  git commit -m "!MSG!"
)
if errorlevel 1 (
  echo 建立版本紀錄失敗。
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

echo.
echo 已存檔並上傳到 GitHub。
pause
