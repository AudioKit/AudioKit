/*
    cwindow.h:

    Copyright (C) 1990 Dan Ellis

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

#ifndef CWINDOW_H
#define CWINDOW_H

/*******************************************************\
*       cwindow.h                                       *
*       portable window graphs stolen from Csound       *
*       necessary header declarations                   *
*       08nov90 dpwe                                    *
\*******************************************************/

#include "csound.h"

#define CAPSIZE  60

struct windat_ {
    uintptr_t windid;           /* set by MakeGraph() */
    MYFLT   *fdata;             /* data passed to DrawGraph */
    int32    npts;               /* size of above array */
    char    caption[CAPSIZE];   /* caption string for graph */
    int16   waitflg;            /* set =1 to wait for ms after Draw */
    int16   polarity;           /* controls positioning of X axis */
    MYFLT   max, min;           /* workspace .. extrema this frame */
    MYFLT   absmax;             /* workspace .. largest of above */
    MYFLT   oabsmax;            /* Y axis scaling factor */
    int     danflag;            /* set to 1 for extra Yaxis mid span */
  int     absflag;             /* set to 1 to skip abs check */
};

enum {                  /* symbols for WINDAT.polarity field */
    NOPOL,
    NEGPOL,
    POSPOL,
    BIPOL
};

struct xyindat_ {       /* for 'joystick' input window */
    uintptr_t windid;   /* xwindow handle */
    int     m_x,m_y;    /* current crosshair pixel adr */
    MYFLT   x,y;        /* current proportions of fsd */
    int     down;
};

 /* ------------------------------------------------------------------------ */

#ifdef __BUILDING_LIBCSOUND

void dispset(CSOUND *, WINDAT *, MYFLT *, int32, char *, int, char *);
int dispexit(CSOUND *);
void display(CSOUND *, WINDAT*);
#if 0
/* create window for a graph */
void MakeGraph(CSOUND *, WINDAT *, const char *);
/* create a mouse input window; init scale */
void MakeXYin(CSOUND *, XYINDAT *, MYFLT, MYFLT);
/* update graph in existing window */
void DrawGraph(CSOUND *, WINDAT *);
/* fetch latest value from mouse input window */
void ReadXYin(CSOUND *, XYINDAT *);
/* remove a graph window */
void KillGraph(CSOUND *, WINDAT *);
/* remove a mouse input window */
void KillXYin(CSOUND *, XYINDAT *);
/* print click-Exit message in most recently active window */
int  ExitGraph(CSOUND *);
#endif

#endif  /*  __BUILDING_LIBCSOUND */

#endif  /*  CWINDOW_H */

