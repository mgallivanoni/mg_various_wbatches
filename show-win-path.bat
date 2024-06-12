::REM print path replacing each semicolon with "& ECHO.", thus
::REM transforming a single command in a sequence of echo commands, one per directory
::REM (all kudos to stacktrace users)
@ECHO.%PATH:;= & ECHO.%
