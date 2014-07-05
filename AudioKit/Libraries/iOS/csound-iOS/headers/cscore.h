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
/**
* \file csound.h
* \section section_api_cscore Cscore
*
* Beginning with Csound 5, all of the Cscore functions described in the
* manual are now part of the Csound API, and they can be called from a program
* that calls the Csound library.
*
* All of the CScore functions are renamed in the Csound API. For
* example, createv() is now cscoreCreateEvent(), and lcopy() is now
* cscoreListCopy().  In addition, each function takes an additional
* first parameter that is a pointer to a CSOUND instance.  You can
* find the details in the header file, cscore.h, which may be
* included with your Csound distribution, or if not, can be found in
* Csound CVS `on SourceForge.
*
* Before you can use any of the Cscore API functions, you must create a CSOUND
* instance and initialize Cscore by calling csoundInitializeCscore() -- see
* csound.h for an explanation.  An example main program that does all of this
* Top/cscormai.c.  You should add a function called cscore() with your own
* score-processing code.  An example that does nothing except write the score
* back out unchanged can be found in the file Top/cscore_internal.c.
*
* To create your own standalone Cscore program, you must compile cscormai.c
* (or your own main program) and the file containing your
* cscore() function, and link them with the Csound API library.
*/

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

#endif
