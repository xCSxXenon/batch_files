<# :
@echo off
setlocal

for /f "delims=" %%a in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
    set "fileName=%%~na"
    set "fileExtension=%%~xa"
    set "filePath=%%~da%%~pa"
)


echo  Selected "%filePath%%fileName%%fileExtension%"
echo.
echo  Filename:         %fileName%
echo  Extension:        %fileExtension:~1%
echo  Path:             %filePath%
pause

goto :EOF

: #>
Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.InitialDirectory = pwd
$f.Filter = "All Files (*.*)|*.*"
$f.ShowHelp = $true
$f.Multiselect = $false
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }

