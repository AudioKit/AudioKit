/*
    csdl.h:

    Copyright (C) 2002 John ffitch

    This file is part of Csound.

    The Csound Library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Csound is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/

#ifndef CSOUND_CSDL_H
#define CSOUND_CSDL_H

#ifdef __BUILDING_LIBCSOUND
#undef __BUILDING_LIBCSOUND
#endif

#include "csoundCore.h"
#include "interlocks.h"

#ifdef __cplusplus
extern "C" {
#endif




#undef Str
#ifndef GNU_GETTEXT
#define Str(x)  (x)
#else
#define Str(x)  (csound->LocalizeString(x))
#endif

PUBLIC  long    csound_opcode_init(CSOUND *, OENTRY **);
PUBLIC  NGFENS  *csound_fgen_init(CSOUND *);

PUBLIC  int     csoundModuleCreate(CSOUND *);
PUBLIC  int     csoundModuleInit(CSOUND *);
PUBLIC  int     csoundModuleDestroy(CSOUND *);
PUBLIC  const char  *csoundModuleErrorCodeToString(int);

PUBLIC  int     csoundModuleInfo(void);

#define LINKAGE                                                         \
PUBLIC long csound_opcode_init(CSOUND *csound, OENTRY **ep)             \
{   (void) csound; *ep = localops; return (long) sizeof(localops);  }   \
PUBLIC int csoundModuleInfo(void)                                       \
{ return ((CS_APIVERSION << 16) + (CS_APISUBVER << 8) + (int) sizeof(MYFLT)); }

#undef LINKAGE1
#define LINKAGE1(name)                                                  \
PUBLIC long csound_opcode_init(CSOUND *csound, OENTRY **ep)             \
{   (void) csound; *ep = name; return (long) (sizeof(name));  }         \
PUBLIC int csoundModuleInfo(void)                                       \
{ return ((CS_APIVERSION << 16) + (CS_APISUBVER << 8) + (int) sizeof(MYFLT)); }

#define FLINKAGE                                                        \
PUBLIC NGFENS *csound_fgen_init(CSOUND *csound)                         \
{   (void) csound; return localfgens;                               }   \
PUBLIC int csoundModuleInfo(void)                                       \
{ return ((CS_APIVERSION << 16) + (CS_APISUBVER << 8) + (int) sizeof(MYFLT)); }

#undef FLINKAGE1
#define FLINKAGE1(name)                                                 \
PUBLIC NGFENS *csound_fgen_init(CSOUND *csound)                         \
{   (void) csound; return name;                                     }   \
PUBLIC int csoundModuleInfo(void)                                       \
{ return ((CS_APIVERSION << 16) + (CS_APISUBVER << 8) + (int) sizeof(MYFLT)); }

#ifdef __cplusplus
}
#endif

#endif      /* CSOUND_CSDL_H */

