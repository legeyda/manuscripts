@ECHO off
SETLOCAL

SET SCRIPT_DIR=%~dp0
SET SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
echo script dir is '%SCRIPT_DIR%'

REM строка с текущей датой
FOR /F "skip=1" %%x IN ('wmic os get localdatetime') DO if not defined WMIC_DATE set WMIC_DATE=%%x
SET TODAY=%WMIC_DATE:~0,4%-%WMIC_DATE:~4,2%-%WMIC_DATE:~6,2%

SET /P TITLE="Case title: "
IF "%TITLE%" == "" GOTO :EOF

REM найдём папку с кейсами
IF "%CASE_HOME%"=="" (
    IF EXIST %USERPROFILE%\case (
        set CASE_HOME=%USERPROFILE%\case
    ) ELSE (
        IF EXIST %SCRIPT_DIR%\..\..\case (
            set CASE_HOME=%SCRIPT_DIR%\..\..\case
        ) else (
            set CASE_HOME=.
        )
    )
)
echo case home is '%CASE_HOME%'

set CASE_DIR=%CASE_HOME%\%TODAY%_%TITLE%
echo this case is %CASE_DIR%
MKDIR "%CASE_DIR%"

REM запускаем текстовый редактор
WHERE code >nul 2>nul
IF %ERRORLEVEL%==0 (
    code --new-window --goto "%CASE_DIR%\note.txt" "%CASE_DIR%"
) else (
    IF EXIST "C:\Program Files\Sublime Text 3\sublime_text.exe" (
        "C:\Program Files\Sublime Text 3\sublime_text.exe" --new-window --add "%CASE_DIR%" "%CASE_DIR%\notes.txt"
    ) ELSE (
	    notepad "%CASE_DIR%\notes.txt"
    )
)

:EOF
ENDLOCAL
