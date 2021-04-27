call nmake -f Bootstrap.mak windows
call premake5 embed
call copy bin\release\premake5.exe c:\bin\ /Y
