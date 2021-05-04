// Premake 5 Glasslight, copy directory.
// Mykola Konyk, 2021

#include <stdlib.h>
#include "premake.h"

int os_copydir(lua_State* L)
{
    int z;
    const char* src = luaL_checkstring(L, 1);
    const char* dst = luaL_checkstring(L, 2);

#if PLATFORM_WINDOWS
    lua_pushfstring(L, "xcopy \"%s\" \"%s\" /Q /E /Y /I ", src, dst);
#else
    lua_pushfstring(L, "cp -rf \"%s\" \"%s\"", src, dst);
#endif

    z = (system(lua_tostring(L, -1)) == 0);

    if (!z)
    {
        lua_pushnil(L);
#if PLATFORM_WINDOWS
        wchar_t buf[256];
        FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError(),
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), buf, 256, NULL);

        char bufA[256];
        WideCharToMultiByte(CP_UTF8, 0, buf, 256, bufA, 256, 0, 0);

        lua_pushfstring(L, "unable to copy dir to '%s', reason: '%s'", dst, bufA);
#else
        lua_pushfstring(L, "unable to copy dir to '%s'", dst);
#endif
        return 2;
    }
    else
    {
        lua_pushboolean(L, 1);
        return 1;
    }
}
