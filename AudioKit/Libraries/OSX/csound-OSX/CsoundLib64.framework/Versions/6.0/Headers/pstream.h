/*
    pstream.h:

    Copyright (C) 2001 Richard Dobson

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

#ifndef __PSTREAM_H_INCLUDED
#define __PSTREAM_H_INCLUDED

/* pstream.h.  Implementation of PVOCEX streaming opcodes.
   (c) Richard Dobson August 2001
   NB pvoc routines based on CARL distribution (Mark Dolson).
   This file is licensed according to the terms of the GNU LGPL.
 */

/* opcodes:     PROVISIONAL DEFINITIONS

  fsig      pvsanal ain,ifftsize,ioverlap,iwinsize,iwintype[,iformat,iinit]

    iwintype:   0 =  HAMMING, 1 =  VonHann, 2 = Kaiser(?)
    iformat:    only PVS_AMP_FREQ (0) supported at present
                (TODO: add f-table support for custom window)
                ( But: really need a param to associate with the window too,
                       or just use a standard default value...)

  fsig      pvsfread ktimpt,ifn[,ichan]

  asig      pvsynth fsig[,iinit]

  asig      pvsadsyn fsig,inoscs,kfmod[,ibin,ibinoffset,iinit]

    ibin:       starting bin (defualt 0)
    ibinoffset: distance between successive bins (default 1)
    kfmod:      multiplier; 1 = no change, 2 = up one octave.

  fsig      pvscross fsrc,fdest,kamp1,kamp2

  fsig      pvsmaska  fsrc,ifn,kdepth

  ioverlap,inumbins,iwinsize,iformat    pvsinfo     fsig

    ( will need sndinfo supporting pvocex files anyway,
      to know numchans, wintype, etc.)

  fdest     =   fsrc

    ( woo-hoo! operator overloading in Csound!)
    ( NB an init statement for fsigs is not supported. One day....)

  kflag     pvsftw fsig,ifna [,ifnf]
            pvsftr fsig,ifna [,ifnf]

    ( this modifies an ~existing~ signal, does not create a new one,
      hence no output)

  Re iinit: not implemented yet: and I still need to establish
                                 if it's possible...
 */

/* description of an fsig analysis frame*/
enum PVS_WINTYPE {
    PVS_WIN_HAMMING = 0,
    PVS_WIN_HANN,
    PVS_WIN_KAISER,
    PVS_WIN_CUSTOM,
    PVS_WIN_BLACKMAN,
    PVS_WIN_BLACKMAN_EXACT,
    PVS_WIN_NUTTALLC3,
    PVS_WIN_BHARRIS_3,
    PVS_WIN_BHARRIS_MIN,
    PVS_WIN_RECT
};


enum PVS_ANALFORMAT {
    PVS_AMP_FREQ = 0,
    PVS_AMP_PHASE,
    PVS_COMPLEX,
    PVS_TRACKS          /* added VL, 24.06.2005 */
};

typedef struct {
  MYFLT re;
  MYFLT im;
} CMPLX;

typedef struct pvsdat {
        int32           N;
        int             sliding; /* Flag to indicate sliding case */
        int32           NB;
        int32           overlap;
        int32           winsize;
        int             wintype;
        int32           format;         /* fixed for now to AMP:FREQ */
        uint32          framecount;
        AUXCH           frame;          /* RWD MUST always be 32bit floats */
                                        /* But not in sliding case when MYFLT */
} PVSDAT;

/* may be no point supporting Kaiser in an opcode unless we can support
   the param too but we can have kaiser in a PVOCEX file. */

typedef struct {
        OPDS    h;
        PVSDAT  *fsig;                  /* output signal is an analysis frame */
        MYFLT   *ain;                   /* input sig is audio */
        MYFLT   *fftsize;               /* params */
        MYFLT   *overlap;
        MYFLT   *winsize;
        MYFLT   *wintype;
        MYFLT   *format;                /* always PVS_AMP_FREQ at present */
        MYFLT   *init;                  /* not yet implemented */
        /* internal */
        int32    buflen;
        float   fund,arate;
        float   RoverTwoPi,TwoPioverR,Fexact;
        MYFLT   *nextIn;
        int32    nI,Ii,IOi;              /* need all these ?; double as N and NB */
        int32    inptr;

        AUXCH   input;
        AUXCH   overlapbuf;
        AUXCH   analbuf;
        AUXCH   analwinbuf;     /* prewin in SDFT case */
        AUXCH   oldInPhase;
        AUXCH           trig;
        double          *cosine, *sine;
} PVSANAL;

typedef struct {
        OPDS    h;
        MYFLT   *aout;                  /* audio output signal */
        PVSDAT  *fsig;                  /* input signal is an analysis frame */
        MYFLT   *init;                  /* not yet implemented */
        /* internal */
        /* check these against fsig vals */
        int32    overlap,winsize,fftsize,wintype,format;
        /* can we allow variant window tpes?  */
        int32    buflen;
        MYFLT   fund,arate;
        MYFLT   RoverTwoPi,TwoPioverR,Fexact;
        MYFLT   *nextOut;
        int32    nO,Ii,IOi;      /* need all these ?*/
        int32    outptr;
        int32    bin_index;      /* for phase normalization across frames */
        /* renderer gets all format info from fsig */

        AUXCH   output;
        AUXCH   overlapbuf;
        AUXCH   synbuf;
        AUXCH   analwinbuf;     /* may get away with a local alloc and free */
        AUXCH   synwinbuf;
        AUXCH   oldOutPhase;

} PVSYNTH;

/* for pvadsyn */

typedef struct {
        OPDS    h;
        MYFLT   *aout;
        PVSDAT  *fsig;
        MYFLT   *n_oscs;
        MYFLT   *kfmod;
        MYFLT   *ibin;          /* default  0 */
        MYFLT   *ibinoffset;    /* default 1  */
        MYFLT   *init;          /* not yet implemented  */
        /* internal */
        int32    outptr;
        uint32   lastframe;
        /* check these against fsig vals */
        int32    overlap,winsize,fftsize,wintype,format,noscs;
        int32    maxosc;
        float   one_over_overlap,pi_over_sr, one_over_sr;
        float   fmod;
        AUXCH   a;
        AUXCH   x;
        AUXCH   y;
        AUXCH   amps;
        AUXCH   lastamps;
        AUXCH   freqs;
        AUXCH   outbuf;
} PVADS;

/* for pvscross */
typedef struct {
        OPDS h;
        PVSDAT  *fout;
        PVSDAT  *fsrc;
        PVSDAT  *fdest;
        MYFLT   *kamp1;
        MYFLT   *kamp2;
        /* internal */
        int32    overlap,winsize,fftsize,wintype,format;
        uint32   lastframe;
} PVSCROSS;

/* for pvsmaska */
typedef struct {
        OPDS    h;
        PVSDAT  *fout;
        PVSDAT  *fsrc;
        MYFLT   *ifn;
        MYFLT   *kdepth;
        /* internal*/
        int32    overlap,winsize,fftsize,wintype,format;
        uint32   lastframe;
        int             nwarned,pwarned;    /* range errors for kdepth */
        FUNC    *maskfunc;
} PVSMASKA;

/* for pvsftw, pvsftr */

typedef struct {
        OPDS    h;
        MYFLT   *kflag;
        PVSDAT  *fsrc;
        MYFLT   *ifna;   /* amp, required */
        MYFLT   *ifnf;   /* freq: optional*/
        /* internal */
        int32    overlap,winsize,fftsize,wintype,format;
        uint32   lastframe;
        FUNC    *outfna, *outfnf;
} PVSFTW;

typedef struct {
        OPDS    h;
        /* no output var*/
        PVSDAT  *fdest;
        MYFLT   *ifna;   /* amp, may be 0 */
        MYFLT   *ifnf;   /* freq: optional*/
        /* internal */
        int32    overlap,winsize,fftsize,wintype,format;
        uint32   lastframe;
        FUNC    *infna, *infnf;
        MYFLT   *ftablea,*ftablef;
} PVSFTR;

/* for pvsfread */
/*  wsig pvsread ktimpt,ifilcod */
typedef struct {
        OPDS h;
        PVSDAT  *fout;
        MYFLT   *kpos;
        MYFLT   *ifilno;
        MYFLT   *ichan;
        /* internal */
        int     ptr;
        int32   overlap,winsize,fftsize,wintype,format;
        uint32  chans, nframes,lastframe,chanoffset,blockalign;
        MYFLT   arate;
        float   *membase;        /* RWD MUST be 32bit: reads file */
} PVSFREAD;

/* for pvsinfo */

typedef struct {
        OPDS    h;
        MYFLT   *ioverlap;
        MYFLT   *inumbins;
        MYFLT   *iwinsize;
        MYFLT   *iformat;
        /* internal*/
        PVSDAT  *fsrc;
} PVSINFO;

typedef struct {
        OPDS    h;
        PVSDAT  *fout;
        PVSDAT  *fsrc;
} FASSIGN;

#endif

