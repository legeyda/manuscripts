rem see https://gist.github.com/xSAVIKx/211f5992aa6d570e63f1022ba695211a
setlocal

rem delete config\eval
cd "%USERPROFILE%\.IntelliJIdea*\config"
rmdir "eval" /s /q

rem delete evaluation data from confg\options.xml
cd options
ren options.xml options.xml.old
findstr /v /c:"evlsprt" options.xml.old > options.xml
del options.xml.old

rem delete evaluation data from registry
reg delete "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\jetbrains\idea" /f

endlocal