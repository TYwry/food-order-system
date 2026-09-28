@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo 這會把 index.html 發布成 GitHub 的「下載版本」，
echo 讓 README 最上方的下載連結可以使用。
echo.
set "TAG="
set /p TAG=請輸入版本號（例如 v1.0）：
if not defined TAG (
  echo 沒有輸入版本號，已取消。
  pause
  exit /b 1
)

gh release create %TAG% "index.html" --title "點餐明細系統 %TAG%" --notes "下載 index.html 後雙擊即可開啟使用。"
if errorlevel 1 (
  echo 發布失敗，請把上面的訊息截圖給協助你的人。
  pause
  exit /b 1
)

echo.
echo 發布完成。
pause
