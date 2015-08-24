/*
    pvfileio.h:

    Copyright (C) 2000 Richard Dobson

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

/* pvfileio.h: header file for PVOC_EX file format */
/* Initial Version 0.1 RWD 25:5:2000 all rights reserved: work in progress! */

#ifndef __PVFILEIO_H_INCLUDED
#define __PVFILEIO_H_INCLUDED

#include "sysdep.h"

#if defined(WIN32) || defined(_WIN32) || defined(_MSC_VER)

#include <windows.h>

#else

typedef struct
{
    uint32_t        Data1;
    uint16_t        Data2;
    uint16_t        Data3;
    unsigned char   Data4[8];
} GUID;

typedef struct /* waveformatex */ {
    uint16_t    wFormatTag;
    uint16_t    nChannels;
    uint32_t    nSamplesPerSec;
    uint32_t    nAvgBytesPerSec;
    uint16_t    nBlockAlign;
    uint16_t    wBitsPerSample;
    uint16_t    cbSize;
} WAVEFORMATEX;

#endif

/* NB no support provided for double format (yet) */

typedef enum pvoc_wordformat {
    PVOC_IEEE_FLOAT,
    PVOC_IEEE_DOUBLE
} pvoc_wordformat;

/* include PVOC_COMPLEX for some parity with SDIF */

typedef enum pvoc_frametype {
    PVOC_AMP_FREQ = 0,
    PVOC_AMP_PHASE,
    PVOC_COMPLEX
} pvoc_frametype;

/* a minimal list */

typedef enum pvoc_windowtype {
    PVOC_DEFAULT = 0,
    PVOC_HAMMING = 0,
    PVOC_HANN,
    PVOC_KAISER,
    PVOC_RECT,
    PVOC_CUSTOM
} pv_wtype;

/* Renderer information: source is presumed to be of this type */

typedef enum pvoc_sampletype {
    STYPE_16,
    STYPE_24,
    STYPE_32,
    STYPE_IEEE_FLOAT
} pv_stype;

typedef struct pvoc_data {   /* 32 bytes */
    uint16_t    wWordFormat;    /* pvoc_wordformat                           */
    uint16_t    wAnalFormat;    /* pvoc_frametype                            */
    uint16_t    wSourceFormat;  /* WAVE_FORMAT_PCM or WAVE_FORMAT_IEEE_FLOAT */
    uint16_t    wWindowType;    /* pvoc_windowtype                           */
    uint32_t    nAnalysisBins;  /* implicit FFT size = (nAnalysisBins-1) * 2 */
    uint32_t    dwWinlen;       /* analysis winlen, in samples               */
                                /*   NB may be != FFT size                   */
    uint32_t    dwOverlap;      /* samples                                   */
    uint32_t    dwFrameAlign;   /* usually nAnalysisBins * 2 * sizeof(float) */
    float       fAnalysisRate;
    float       fWindowParam;   /* default 0.0f unless needed                */
} PVOCDATA;

typedef struct {
    WAVEFORMATEX    Format;                 /* 18 bytes: info for renderer   */
                                            /*           as well as for pvoc */
    union {                                 /* 2 bytes */
      uint16_t      wValidBitsPerSample;    /* as per standard WAVE_EX:      */
                                            /*           applies to renderer */
      uint16_t      wSamplesPerBlock;
      uint16_t      wReserved;
    } Samples;
    uint32_t        dwChannelMask;          /* 4 bytes: can be used as in    */
                                            /*          standrad WAVE_EX     */
    GUID            SubFormat;              /* 16 bytes */
} WAVEFORMATEXTENSIBLE, *PWAVEFORMATEXTENSIBLE;

typedef struct {
    WAVEFORMATEXTENSIBLE wxFormat;  /* 40 bytes                              */
    uint32_t    dwVersion;          /* 4 bytes                               */
    uint32_t    dwDataSize;         /* 4 bytes: sizeof PVOCDATA data block   */
    PVOCDATA    data;               /* 32 bytes                              */
} WAVEFORMATPVOCEX;                 /* total 80 bytes                        */

/* at least VC++ will give 84 for sizeof(WAVEFORMATPVOCEX), */
/* so we need our own version */
#define SIZEOF_FMTPVOCEX    (80)
/* for the same reason: */
#define SIZEOF_WFMTEX       (18)
#define PVX_VERSION         (1)

/******* the all-important PVOC GUID

 {8312B9C2-2E6E-11d4-A824-DE5B96C3AB21}

**************/

#ifndef CSOUND_CSDL_H

extern  const GUID KSDATAFORMAT_SUBTYPE_PVOC;

/* pvoc file handling functions */

const char *pvoc_errorstr(CSOUND *);
int     init_pvsys(CSOUND *);
int     pvoc_createfile(CSOUND *, const char *,
                        uint32, uint32, uint32,
                        uint32, int32, int, int,
                        float, float *, uint32);
int     pvoc_openfile(CSOUND *,
                      const char *filename, void *data_, void *fmt_);
int     pvoc_closefile(CSOUND *, int);
int     pvoc_putframes(CSOUND *,
                       int ofd, const float *frame, int32 numframes);
int     pvoc_getframes(CSOUND *,
                       int ifd, float *frames, uint32 nframes);
int     pvoc_framecount(CSOUND *, int ifd);
int     pvoc_fseek(CSOUND *, int ifd, int offset);
int     pvsys_release(CSOUND *);

#endif  /* CSOUND_CSDL_H */

#endif  /* __PVFILEIO_H_INCLUDED */

