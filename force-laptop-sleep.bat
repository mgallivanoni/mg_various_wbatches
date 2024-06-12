@echo off

::REM entering the folder where this batch script is located
CD /d C:\tmp\force-win-sleep\

::REM change thes evariables to fit your scenario
set THE_LOG=".\00--force_sleep_log.txt"
set START_WTIME=0830
set END_WTIME=1810

::REM flag file to prevent sending the laptop to sleep
set USER_SAID_NO=".\no-thanks"
set office_network_prefix=191.168.111
set home_network_prefix=191.168.222

::REM a simple check to verify this batch is run with admin permissions
net session >nul 2>&1
if %errorLevel% == 0 (
        echo Administrative permissions confirmed - good
    ) else (
        echo Failure: Current permissions inadequate - exiting
        exit 1
)

:the_beginning
del zl.txt l.txt >NUL 2>&1

ipconfig /all | find "IPv4" | find "%office_network_prefix%" > zl.txt
ipconfig /all | find "IPv4" | find "%home_network_prefix%" >> zl.txt

::REM CHECK EVERY 10 seconds if we are in the office or at home
SLEEP 10
::REM the sleep command above may help mocking zl.txt when testing this batch script

type zl.txt | find /c "." > l.txt

for /f "delims=," %%i in ('type l.txt') DO set laptop_in_office=%%i

echo "laptop_in_office is <<%laptop_in_office%>>"  >>%THE_LOG%

if %laptop_in_office% gtr 0 goto the_beginning

::REM NOW CHECK IF WE ARE OUTSIDE WORKING HOURS
for /f "delims=: tokens=1,2" %%i in ('echo %time%') DO echo %%i%%j > l.txt

sleep 10
::REM NB: the sleep command above may help mocking l.txt when testing this batch script

for /f "delims=," %%i in ('type l.txt') DO set ttime=%%i

echo "current time is <<%ttime%>>"  >>%THE_LOG%

if %ttime% gtr %END_WTIME%  goto proceed
if %START_WTIME% gtr %ttime%  goto proceed
::REM if we reach this point it is working hours so we need to go back to the beginning and wait 
goto the_beginning

:proceed

echo IF WE REACH THIS FAR WE NEED TO SEND SHUTDOWN/SLEEP!!!!!!!!!!!!!!!!!!!!!! >>%THE_LOG%

echo.  >>%THE_LOG%
if  exist "%USER_SAID_NO%" (
   echo no-thanks file found at %time% - sleep suppressed  >>%THE_LOG%
)


if not exist "%USER_SAID_NO%" (
     powershell "[console]::beep(500,300)"

     echo wait  2 minutes then suspend >>%THE_LOG%
     ::REM 2 minutes should been enough for emergency recovery to
     ::REM stop suspend loops from going berserk
     sleep 120

     powershell "[console]::beep(500,300)"
     powershell "[console]::beep(500,300)"
     powershell "[console]::beep(500,300)"

     echo send laptop to 'powrprof.dll,SetSuspendState 0,1,0' %time% >>%THE_LOG%
     rundll32.exe powrprof.dll,SetSuspendState 0,1,0
     echo the rundll command for sleep has been launched >>%THE_LOG%
	 
)

::REM NB: this is an infinite loop - you may terminate it with CTRL-C when needed
goto the_beginning
