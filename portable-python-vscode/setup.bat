@echo off
REM 実行ポリシーの事前確認
REM グループポリシーで実行ポリシーが決められていると -ExecutionPolicy Bypass は無視される
set "EFFECTIVE_POLICY="
for /f "usebackq delims=" %%P in (`powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ExecutionPolicy"`) do set "EFFECTIVE_POLICY=%%P"
if /i "%EFFECTIVE_POLICY%"=="Restricted" goto :policy_blocked
if /i "%EFFECTIVE_POLICY%"=="AllSigned" goto :policy_blocked

powershell.exe -ExecutionPolicy Bypass -Command "Unblock-File -Path '%~dp0setup.ps1'"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

if errorlevel 1 exit /b 1

echo --- Script finished ---
pause
exit /b 0

:policy_blocked
echo.
echo [エラー] この PC では、グループポリシーによって PowerShell スクリプトの実行が制限されています。
echo         有効な実行ポリシー: %EFFECTIVE_POLICY%
echo         setup.bat からはこの設定を変更できないため、PC の管理者に相談してください。
echo.
echo [対策]
echo   1. 制限のない別の PC で setup.bat を実行し、できあがった
echo      portable-python-vscode フォルダーごとこの PC にコピーするか、
echo      USB メモリのまま持ってきてください。
echo      この PC では launch-vscode.bat で起動するだけなので、実行ポリシーの影響を受けません。
echo   2. PC の管理者に、実行ポリシーを RemoteSigned にしてもらうよう依頼してください。
echo   詳しくは次のページの「5. 実行ポリシーが制限されている PC で使う」を参照してください。
echo   https://github.com/kawaba/autosetup-vscode-python-book
echo.
echo 現在の実行ポリシーの一覧 [Get-ExecutionPolicy -List]:
powershell.exe -NoProfile -Command "Get-ExecutionPolicy -List | Format-Table -AutoSize | Out-String"
pause
exit /b 1
