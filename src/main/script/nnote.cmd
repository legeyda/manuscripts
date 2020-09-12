@ECHO off
SETLOCAL

SET SCRIPT_DIR=%~dp0
SET SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
REM ECHO script dir is '%SCRIPT_DIR%'

REM строка с текущей датой
FOR /F "skip=1" %%x IN ('wmic os get localdatetime') DO if not defined WMIC_DATE set WMIC_DATE=%%x
SET TODAY=%WMIC_DATE:~0,4%-%WMIC_DATE:~4,2%-%WMIC_DATE:~6,2%

SET /P TITLE="Note title: "
IF "%TITLE%" == "" GOTO :EOF

REM найдём папку с заметками
IF "%NOTE_HOME%"=="" (
    IF EXIST %USERPROFILE%\notes (
        set NOTE_HOME=%USERPROFILE%\notes
    ) ELSE (
        IF EXIST %SCRIPT_DIR%\..\..\notes (
            set NOTE_HOME=%SCRIPT_DIR%\..\..\notes
        ) else (
            set NOTE_HOME=.
        )
    )
)
echo note home is '%NOTE_HOME%'

set NOTE_FILE=%NOTE_HOME%\%TODAY%_%TITLE%.txt
echo this note is %NOTE_FILE%

REM найдём текстовый редактор
WHERE code >nul 2>nul
IF %ERRORLEVEL%==0 (
    code "%NOTE_FILE%"
) else (
    IF EXIST "C:\Program Files\Sublime Text 3\sublime_text.exe" (
        "C:\Program Files\Sublime Text 3\sublime_text.exe" "%NOTE_FILE%"
    ) ELSE (
        code "%NOTE_FILE%"
    )
)

:EOF
ENDLOCAL
