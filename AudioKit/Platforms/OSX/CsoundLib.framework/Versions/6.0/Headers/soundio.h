/*
    soundio.h:

    Copyright (C) 1991, 2000 Barry Vercoe, Richard Dobson

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
                                /*                      SOUNDIO.H       */
#ifndef CSOUND_SOUNDIO_H
#define CSOUND_SOUNDIO_H

#include <sndfile.h>

#ifdef WIN32
#define IOBUFSAMPS   4096   /* default sampframes in audio iobuf, -b settable */
#define IODACSAMPS   16384  /* default samps in hardware buffer,  -B settable */
#elif defined(NeXT) || defined(__MACH__)
#define IOBUFSAMPS   1024   /* default sampframes in audio iobuf, -b settable */
#define IODACSAMPS   4096   /* default samps in hardware buffer,  -B settable */
#elif defined(ANDROID)
#define IOBUFSAMPS   2048   /* default sampframes in audio iobuf, -b settable */
#define IODACSAMPS   4096   /* default samps in hardware buffer,  -B settable */
#else
#define IOBUFSAMPS   256    /* default sampframes in audio iobuf, -b settable */
#define IODACSAMPS   1024   /* default samps in hardware buffer,  -B settable */
#endif

#define SNDINBUFSIZ  4096   /* soundin bufsize;   must be > sizeof(SFHEADER), */
                            /*                 but small is kind to net rexec */
#define MAXSNDNAME   1024
/* standard audio encoding types */

#define AE_CHAR         SF_FORMAT_PCM_S8
#define AE_SHORT        SF_FORMAT_PCM_16
#define AE_24INT        SF_FORMAT_PCM_24
#define AE_LONG         SF_FORMAT_PCM_32
#define AE_UNCH         SF_FORMAT_PCM_U8
#define AE_FLOAT        SF_FORMAT_FLOAT
#define AE_DOUBLE       SF_FORMAT_DOUBLE
#define AE_ULAW         SF_FORMAT_ULAW
#define AE_ALAW         SF_FORMAT_ALAW
#define AE_IMA_ADPCM    SF_FORMAT_IMA_ADPCM
#define AE_MS_ADPCM     SF_FORMAT_MS_ADPCM
#define AE_GSM610       SF_FORMAT_GSM610
#define AE_VOX          SF_FORMAT_VOX_ADPCM
#define AE_G721_32      SF_FORMAT_G721_32
#define AE_G723_24      SF_FORMAT_G723_24
#define AE_G723_40      SF_FORMAT_G723_40
#define AE_DWVW_12      SF_FORMAT_DWVW_12
#define AE_DWVW_16      SF_FORMAT_DWVW_16
#define AE_DWVW_24      SF_FORMAT_DWVW_24
#define AE_DWVW_N       SF_FORMAT_DWVW_N
#define AE_DPCM_8       SF_FORMAT_DPCM_8
#define AE_DPCM_16      SF_FORMAT_DPCM_16
#define AE_VORBIS       SF_FORMAT_VORBIS

#define AE_LAST   SF_FORMAT_DPCM_16     /* current last audio encoding value */

/* file types */

#define TYP_WAV   (SF_FORMAT_WAV >> 16)
#define TYP_AIFF  (SF_FORMAT_AIFF >> 16)
#define TYP_AU    (SF_FORMAT_AU >> 16)
#define TYP_RAW   (SF_FORMAT_RAW >> 16)
#define TYP_PAF   (SF_FORMAT_PAF >> 16)
#define TYP_SVX   (SF_FORMAT_SVX >> 16)
#define TYP_NIST  (SF_FORMAT_NIST >> 16)
#define TYP_VOC   (SF_FORMAT_VOC >> 16)
#define TYP_IRCAM (SF_FORMAT_IRCAM >> 16)
#define TYP_W64   (SF_FORMAT_W64 >> 16)
#define TYP_MAT4  (SF_FORMAT_MAT4 >> 16)
#define TYP_MAT5  (SF_FORMAT_MAT5 >> 16)
#define TYP_PVF   (SF_FORMAT_PVF >> 16)
#define TYP_XI    (SF_FORMAT_XI >> 16)
#define TYP_HTK   (SF_FORMAT_HTK >> 16)
#define TYP_SDS   (SF_FORMAT_SDS >> 16)
#define TYP_AVR   (SF_FORMAT_AVR >> 16)
#define TYP_WAVEX (SF_FORMAT_WAVEX >> 16)
#define TYP_SD2   (SF_FORMAT_SD2 >> 16)
#define TYP_FLAC  (SF_FORMAT_FLAC >> 16)
#define TYP_CAF   (SF_FORMAT_CAF >> 16)
#define TYP_WVE   (SF_FORMAT_WVE >> 16)
#define TYP_OGG   (SF_FORMAT_OGG >> 16)
#define TYP_MPC2K (SF_FORMAT_MPC2K >> 16)
#define TYP_RF64  (SF_FORMAT_RF64 >> 16)

#define FORMAT2SF(x) ((int) (x))
#define SF2FORMAT(x) ((int) (x) & 0xFFFF)
#define TYPE2SF(x)   ((int) (x) << 16)
#define SF2TYPE(x)   ((int) (x& SF_FORMAT_TYPEMASK) >> 16)

#ifdef  USE_DOUBLE
#define sf_write_MYFLT  sf_write_double
#define sf_read_MYFLT   sf_read_double
#else
#define sf_write_MYFLT  sf_write_float
#define sf_read_MYFLT   sf_read_float
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* generic sound input structure */

typedef struct {
        SNDFILE *sinfd;             /* sound file handle                    */
        MYFLT   *inbufp, *bufend;   /* current buffer position, end of buf  */
        void    *fd;                /* handle returned by csoundFileOpen()  */
        int     bufsmps;            /* number of mono samples in buffer     */
        int     format;             /* sample format (AE_SHORT, etc.)       */
        int     channel;            /* requested channel (ALLCHNLS: all)    */
        int     nchanls;            /* number of channels in file           */
        int     sampframsiz;        /* sample frame size in bytes           */
        int     filetyp;            /* file format (TYP_WAV, etc.)          */
        int     analonly;           /* non-zero for analysis utilities      */
        int     endfile;            /* end of file reached ? non-zero: yes  */
        int     sr;                 /* sample rate in Hz                    */
        int     do_floatscaling;    /* scale floats by fscalefac ? 0: no    */
        int64_t audrem, framesrem, getframes;   /* samples, frames, frames */
        MYFLT   fscalefac;
        MYFLT   skiptime;
        char    sfname[MAXSNDNAME];
        MYFLT   inbuf[SNDINBUFSIZ];
} SOUNDIN;

#ifdef __cplusplus
}
#endif

#endif      /* CSOUND_SOUNDIO_H */

