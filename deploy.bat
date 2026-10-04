@echo off
chcp 65001 >nul
cd /d "%~dp0"
where node >nul 2>nul || (echo 找不到 Node.js，請先安裝：https://nodejs.org & pause & exit /b 1)
where firebase >nul 2>nul || (echo 找不到 Firebase 工具，請先執行：npm install -g firebase-tools & pause & exit /b 1)
if not exist ".firebaserc" (echo 找不到 .firebaserc，請先填入 Firebase 專案 ID & pause & exit /b 1)
findstr /c:"your-firebase-project-id" ".firebaserc" >nul && (echo 請先用記事本打開 .firebaserc，把 your-firebase-project-id 換成你的 Firebase 專案 ID & pause & exit /b 1)
node scripts\bump-version.js || (pause & exit /b 1)
call firebase deploy --only hosting
if errorlevel 1 (echo 部署失敗，請看上面的錯誤訊息 & pause & exit /b 1)
echo.
echo 部署完成！手機下次開啟 App 就會換成新版，資料不受影響。
pause
