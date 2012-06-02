/*
    cscore.h:

    Copyright (C) 1991 Barry Vercoe, John ffitch

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

#ifndef  CSCORE_H
#define  CSCORE_H

#include <stdio.h>

#ifndef MYFLT
#include "sysdep.h"
#endif
#include "csound.h"

typedef struct cshdr {
        struct cshdr *prvblk;
        struct cshdr *nxtblk;
        int16  type;
        int16  size;
} CSHDR;

/* Single score event structure */
typedef struct {
        CSHDR h;
        char  *strarg;
        char  op;
        int16 pcnt;
        MYFLT p2orig;
        MYFLT p3orig;
        MYFLT p[1];
} EVENT;

/* Event list structure */
typedef struct {
        CSHDR h;
        int   nslots;
        int   nevents;
        EVENT *e[1];
} EVLIST;

/* This pragma must come before all public function declarations */
#if (defined(macintosh) && defined(__MWERKS__))
#  pragma export on
#endif

/* Functions for working with single events */
PUBLIC EVENT  *cscoreCreateEvent(CSOUND*, int);
PUBLIC EVENT  *cscoreDefineEvent(CSOUND*, char*);
PUBLIC EVENT  *cscoreCopyEvent(CSOUND*, EVENT*);
PUBLIC EVENT  *cscoreGetEvent(CSOUND*);
PUBLIC void    cscorePutEvent(CSOUND*, EVENT*);
PUBLIC void    cscorePutString(CSOUND*, char*);

/* Functions for working with event lists */
PUBLIC EVLIST *cscoreListCreate(CSOUND*, int);
PUBLIC EVLIST *cscoreListAppendEvent(CSOUND*, EVLIST*, EVENT*);
PUBLIC EVLIST *cscoreListAppendStringEvent(CSOUND*, EVLIST*, char*);
PUBLIC EVLIST *cscoreListGetSection(CSOUND*);
PUBLIC EVLIST *cscoreListGetNext(CSOUND *, MYFLT);
PUBLIC EVLIST *cscoreListGetUntil(CSOUND*, MYFLT);
PUBLIC EVLIST *cscoreListCopy(CSOUND*, EVLIST*);
PUBLIC EVLIST *cscoreListCopyEvents(CSOUND*, EVLIST*);
PUBLIC EVLIST *cscoreListExtractInstruments(CSOUND*, EVLIST*, char*);
PUBLIC EVLIST *cscoreListExtractTime(CSOUND*, EVLIST*, MYFLT, MYFLT);
PUBLIC EVLIST *cscoreListSeparateF(CSOUND*, EVLIST*);
PUBLIC EVLIST *cscoreListSeparateTWF(CSOUND*, EVLIST*);
PUBLIC EVLIST *cscoreListAppendList(CSOUND*, EVLIST*, EVLIST*);
PUBLIC EVLIST *cscoreListConcatenate(CSOUND*, EVLIST*, EVLIST*);
PUBLIC void    cscoreListPut(CSOUND*, EVLIST*);
PUBLIC int     cscoreListPlay(CSOUND*, EVLIST*);
PUBLIC void    cscoreListSort(CSOUND*, EVLIST*);
PUBLIC int     cscoreListCount(CSOUND*, EVLIST *);

/* Functions for reclaiming memory */
PUBLIC void    cscoreFreeEvent(CSOUND*, EVENT*);
PUBLIC void    cscoreListFree(CSOUND*, EVLIST*);
PUBLIC void    cscoreListFreeEvents(CSOUND*, EVLIST*);

/* Functions for working with multiple input score files */
PUBLIC FILE   *cscoreFileOpen(CSOUND*, char*);
PUBLIC void    cscoreFileClose(CSOUND*, FILE*);
PUBLIC FILE   *cscoreFileGetCurrent(CSOUND*);
PUBLIC void    cscoreFileSetCurrent(CSOUND*, FILE*);

/* This pragma must come after all public function declarations */
#if (defined(macintosh) && defined(__MWERKS__))
#  pragma export off
#endif

#endif
