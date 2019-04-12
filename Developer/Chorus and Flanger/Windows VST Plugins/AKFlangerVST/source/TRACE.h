// TRACE macro for win32
#pragma once

#include <crtdbg.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#ifdef _DEBUG
#define TRACEMAXSTRING  1024

static char szBuffer[TRACEMAXSTRING];
inline void TRACE(const char* format,...)
{
    va_list args;
    va_start(args,format);
    int nBuf;
    nBuf = _vsnprintf(szBuffer,
                   TRACEMAXSTRING,
                   format,
                   args);
    va_end(args);

    _RPT0(_CRT_WARN,szBuffer);
}

#define TRACEF _snprintf(szBuffer,TRACEMAXSTRING,"%s(%d): ", \
                &strrchr(__FILE__,'\\')[1],__LINE__); \
                _RPT0(_CRT_WARN,szBuffer); \
                TRACE
#else
// Remove for release mode
#define TRACE  ((void)__noop)
#define TRACEF ((void)__noop)
#endif
