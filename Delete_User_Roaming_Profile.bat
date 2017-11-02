@ECHO off
REM Purpose: Remotely access the C$ shares of a numerical series of servers and delete their local user profile.
REM Then access the network share containing the master roaming profile and rename it.
REM The primary reason is to wipe out corrupted NTUSER.dat profiles to be regenerated.
REM This is highly beneficial if their roaming profile and folder redirect folders are separate,
REM otherwise you will need to migrate over much of their AppData, Desktop, Documents, etc.
REM WARNING: Server will be very upset if the NTUSER.dat is missing while registry pointers still exist; REMOVE registry pointers!


REM ------------------------------------------------------
REM Created 2017.08.29 v1.0 by Drew W.
REM Updated 2017.09.14 v1.1 by Drew W. - Updated for looping numerically through Terminal Servers
REM Updated 2017.09.18 v1.2 by Drew W. - Added /-y  for prompt overwrite of MOVE of TS_Profiles directory
REM ------------------------------------------------------

REM ------------- EDIT THESE TO ENVIRONMENT -------------------------------------
SET domain=<DOMAIN>
SET roamingProfileDirectory=<BASE DIRECTORY OF ROAMING PROFILE e.g. \\fileshare\ts_profiles>
SET logDirectory=<NETWORK LOG DIRECTORY e.g. \\fileshare\IT\logs>
SET terminalServers=<COMMON NAME BASE e.g. term-serv (term-serv1... term-serv5>
REM -----------------------------------------------------------------------------

SET HOUR=%time:~0,2%
SET dtStamp9=%date:~-4%%date:~4,2%%date:~7,2%_0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
IF "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)


SET /p adminUser="Enter admin username: "
ECHO.


SET /p user="Enter initials to be deleted: "
ECHO.

RUNAS /savecred /user:%domain%\%adminUser% "cmd /c ECHO deleting profile %user% on %date% > %logDirectory%\%dtStamp%.DELUserProfile.%user%.txt"
ECHO.

SET loopcount=12
:loop
ECHO "Deleting profile %user% on %terminalServers%%loopcount%"
RUNAS /savecred /user:%domain%\%adminUser% "cmd /c RMDIR \\%terminalServers%%loopcount%\c$\Users\%user% /s /q"
ECHO.
SET /a loopcount=loopcount-1
IF %loopcount%==0 GOTO exitloop
GOTO loop


:exitloop
RUNAS /savecred /user:%domain%\%adminUser% "cmd /c MOVE /-y %roamingProfileDirectory%\%user% %roamingProfileDirectory%\%user%.OLD"
ECHO. 
ECHO Press any key to exit...
PAUSE > NUL