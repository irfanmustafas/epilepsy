@echo off
echo Attempting to update from remote repository...
git pull origin master >NUL 2>NUL
if %errorlevel%==0 echo Update completed successfully.
if not %errorlevel%==0 echo Something went wrong! Email will@faithfull.me
pause