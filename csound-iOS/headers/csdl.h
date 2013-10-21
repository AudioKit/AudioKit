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
/**
* \file csdl.h
*
* \brief Declares the Csound plugin opcode interface.
* \author John P. ffitch, Michael Gogins, Matt Ingalls, John D. Ramsdell,
*         Istvan Varga, Victor Lazzarini.
*
* Plugin opcodes can extend the functionality of Csound, providing new
* functionality that is exposed as opcodes in the Csound language.
* Plugins need to include this header file only, as it will bring all necessary
* data structures to interact with Csound. It is not necessary for plugins
* to link to the libcsound library, as plugin opcodes will always receive a
* CSOUND* pointer (to the CSOUND_ struct) which contains all the API functions
* inside.
*
* This is the basic template for a plugin opcode. See the manual for further
* details on accepted types and function call rates. The use of the LINKAGE
* macro is highly recommended, rather than calling the functions directly.
*
* \code
#include "csdl.h"

typedef struct {
   OPDS h;
   MYFLT *out;
   MYFLT *in1, *in2;
} OPCODE;

static int op_init(CSOUND *csound, OPCODE *p)
{
// Intialization code goes here
    return OK;
}

static int op_k(CSOUND *csound, OPCODE *p)
{
// code called at k-rate goes here
    return OK;
}

// You can use these functions if you need to prepare and cleanup things on
// loading/unloading the library, but they can be absent if you don't need them

PUBLIC int csoundModuleCreate(CSOUND *csound)
{
    return 0;
}

PUBLIC int csoundModuleInit(CSOUND *csound)
{
    OENTRY  *ep = (OENTRY *) &(localops[0]);
    int     err = 0;
    while (ep->opname != NULL) {
      err |= csound->AppendOpcode(csound,
                                  ep->opname, ep->dsblksiz, ep->thread,
                                  ep->outypes, ep->intypes,
                                  (int (*)(CSOUND *, void *)) ep->iopadr,
                                  (int (*)(CSOUND *, void *)) ep->kopadr,
                                  (int (*)(CSOUND *, void *)) ep->aopadr);
      ep++;
    }
    return err;
}

PUBLIC int csoundModuleDestroy(CSOUND *csound)
{
    // Called when the plugin opcode is unloaded, usually when Csound terminates.
    return 0;
}

static OENTRY localops[] =
{
  { "opcode",   sizeof(OPCODE),  0, 3, "i",    "ii", (SUBR)op_init, (SUBR)op_k }}
};

LINKAGE(localops)

*
* \endcode
**/

#ifdef __BUILDING_LIBCSOUND
#undef __BUILDING_LIBCSOUND
#endif
#include "interlocks.h"
#include "csoundCore.h"


#ifdef __cplusplus
extern "C" {
#endif

/* Use the Str() macro for translations of strings */
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

/** The LINKAGE macro sets up linking of opcode list*/

#define LINKAGE                                                         \
PUBLIC long csound_opcode_init(CSOUND *csound, OENTRY **ep)             \
{   (void) csound; *ep = localops; return (long) sizeof(localops);  }   \
PUBLIC int csoundModuleInfo(void)                                       \
{ return ((CS_APIVERSION << 16) + (CS_APISUBVER << 8) + (int) sizeof(MYFLT)); }

/** The LINKAGE_BUILTIN macro sets up linking of opcode list for builtin opcodes
 * which must have unique function names */

#undef LINKAGE_BUILTIN
#define LINKAGE_BUILTIN(name)                                           \
PUBLIC long csound_opcode_init(CSOUND *csound, OENTRY **ep)             \
{   (void) csound; *ep = name; return (long) (sizeof(name));  }         \
PUBLIC int csoundModuleInfo(void)                                       \
{ return ((CS_APIVERSION << 16) + (CS_APISUBVER << 8) + (int) sizeof(MYFLT)); }

/** LINKAGE for f-table plugins */

#define FLINKAGE                                                        \
PUBLIC NGFENS *csound_fgen_init(CSOUND *csound)                         \
{   (void) csound; return localfgens;                               }   \
PUBLIC int csoundModuleInfo(void)                                       \
{ return ((CS_APIVERSION << 16) + (CS_APISUBVER << 8) + (int) sizeof(MYFLT)); }

#undef FLINKAGE_BUILTIN
#define FLINKAGE_BUILTIN(name)                                          \
PUBLIC NGFENS *csound_fgen_init(CSOUND *csound)                         \
{   (void) csound; return name;                                     }   \
PUBLIC int csoundModuleInfo(void)                                       \
{ return ((CS_APIVERSION << 16) + (CS_APISUBVER << 8) + (int) sizeof(MYFLT)); }

#ifdef __cplusplus
}
#endif

#endif      /* CSOUND_CSDL_H */

