/*
    csoundCore.h:

    Copyright (C) 1991-2006 Barry Vercoe, John ffitch, Istvan Varga

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

#if !defined(__BUILDING_LIBCSOUND) && !defined(CSOUND_CSDL_H)
#  error "Csound plugins and host applications should not include csoundCore.h"
#endif

#ifndef CSOUNDCORE_H
#define CSOUNDCORE_H

#include "sysdep.h"
#ifndef EMSCRIPTEN
#include <pthread.h>
#endif
#include "cs_par_structs.h"
#include <stdarg.h>
#include <setjmp.h>
#include "csound_type_system.h"
#include "csound.h"
#include "cscore.h"
#include "csound_data_structures.h"
#include "csound_standard_types.h"
#include "pools.h"

#ifndef CSOUND_CSDL_H
/* VL not sure if we need to check for SSE */
#ifdef __SSE__
#ifndef _MM_DENORMALS_ZERO_ON
#include <xmmintrin.h>
#define _MM_DENORMALS_ZERO_MASK   0x0040
#define _MM_DENORMALS_ZERO_ON     0x0040
#define _MM_DENORMALS_ZERO_OFF    0x0000
#define _MM_SET_DENORMALS_ZERO_MODE(mode)                                   \
            _mm_setcsr((_mm_getcsr() & ~_MM_DENORMALS_ZERO_MASK) | (mode))
#define _MM_GET_DENORMALS_ZERO_MODE()                                       \
            (_mm_getcsr() & _MM_DENORMALS_ZERO_MASK)
#endif
#else
#define _MM_DENORMALS_ZERO_MASK   0
#define _MM_DENORMALS_ZERO_ON     0
#define _MM_DENORMALS_ZERO_OFF    0
#define _MM_SET_DENORMALS_ZERO_MODE(mode)
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif /*  __cplusplus */

#ifdef __MACH__
#include <xlocale.h>
#endif

#if (defined(__MACH__) || defined(ANDROID) || defined(NACL))
#define BARRIER_SERIAL_THREAD (-1)
typedef struct {
  pthread_mutex_t mut;
  pthread_cond_t cond;
  unsigned int count, max, iteration;
} barrier_t;

#ifndef PTHREAD_BARRIER_SERIAL_THREAD
#define pthread_barrier_t barrier_t
#endif /* PTHREAD_BARRIER_SERIAL_THREAd */
#endif /* __MACH__ */

#define OK        (0)
#define NOTOK     (-1)

#define CSFILE_FD_R     1
#define CSFILE_FD_W     2
#define CSFILE_STD      3
#define CSFILE_SND_R    4
#define CSFILE_SND_W    5

#define MAXINSNO  (200)
#define PMAX      (1998)
#define VARGMAX   (1999)

#define ORTXT       h.optext->t
#define INCOUNT     ORTXT.inlist->count
#define OUTCOUNT    ORTXT.outlist->count   /* Not used */
//#define INOCOUNT    ORTXT.inoffs->count
//#define OUTOCOUNT   ORTXT.outoffs->count
#define INOCOUNT    ORTXT.inArgCount
#define OUTOCOUNT   ORTXT.outArgCount
#define IS_ASIG_ARG(x) (csoundGetTypeForArg(x) == &CS_VAR_TYPE_A)
#define IS_STR_ARG(x) (csoundGetTypeForArg(x) == &CS_VAR_TYPE_S)

#define CURTIME (((double)csound->icurTime)/((double)csound->esr))
#define CURTIME_inc (((double)csound->ksmps)/((double)csound->esr))

#ifdef  B64BIT
#define MAXLEN     0x40000000
#define FMAXLEN    ((MYFLT)(MAXLEN))
#define PHMASK     0x3fffffff
#else
#define MAXLEN     0x1000000L
#define FMAXLEN    ((MYFLT)(MAXLEN))
#define PHMASK     0x0FFFFFFL
#endif

#define MAX_STRING_CHANNEL_DATASIZE 16384

#define PFRAC(x)   ((MYFLT)((x) & ftp->lomask) * ftp->lodiv)
#define MAXPOS     0x7FFFFFFFL

#define BYTREVS(n) ((n>>8  & 0xFF) | (n<<8 & 0xFF00))
#define BYTREVL(n) ((n>>24 & 0xFF) | (n>>8 & 0xFF00L) | \
                    (n<<8 & 0xFF0000L) | (n<<24 & 0xFF000000L))

#define OCTRES     8192
#define CPSOCTL(n) ((MYFLT)(1<<((int)(n)>>13))*csound->cpsocfrc[(int)(n)&8191])

#define LOBITS     10
#define LOFACT     1024
  /* LOSCAL is 1/LOFACT as MYFLT */
#define LOSCAL     FL(0.0009765625)

#define LOMASK     1023

#ifdef USE_DOUBLE
  extern int64_t MYNAN;
  //#define SSTRCOD    (nan("0"))
#define SSTRCOD    (double)NAN
#else
  extern int32 MYNAN;
#define SSTRCOD    (float)NAN
  //#define SSTRCOD    (nanf("0"))
#endif
#define ISSTRCOD(X) isnan(X)

#define SSTRSIZ    1024
#define ALLCHNLS   0x7fff
#define DFLT_SR    FL(44100.0)
#define DFLT_KR    FL(4410.0)
#define DFLT_KSMPS 10
#define DFLT_NCHNLS 1
#define MAXCHNLS   256

#define MAXNAME   (256)

#define DFLT_DBFS (FL(32768.0))

#define MAXOCTS         8
#define MAXCHAN         16      /* 16 MIDI channels; only one port for now */

#define ONEPT           1.02197486              /* A440 tuning factor */
#define LOG10D20        0.11512925              /* for db to ampfac   */
#define DV32768         FL(0.000030517578125)

#ifndef PI
#define PI      (3.141592653589793238462643383279502884197)
#endif /* pi */
#define TWOPI   (6.283185307179586476925286766559005768394)
#define PI_F    ((MYFLT) PI)
#define TWOPI_F ((MYFLT) TWOPI)
#define INF     (2147483647.0)

#define AMPLMSG 01
#define RNGEMSG 02
#define WARNMSG 04
#define RAWMSG  0x40
#define TIMEMSG 0x80
#define IGN(X)  (void) X

#define ARG_CONSTANT 0
#define ARG_STRING 1
#define ARG_PFIELD 2
#define ARG_GLOBAL 3
#define ARG_LOCAL 4
#define ARG_LABEL 5

#define ASYNC_GLOBAL 1
#define ASYNC_LOCAL  2

  typedef struct CORFIL {
    char    *body;
    unsigned int     len;
    unsigned int     p;
  } CORFIL;

  typedef struct {
    int     odebug;
    int     sfread, sfwrite, sfheader, filetyp;
    int     inbufsamps, outbufsamps;
    int     informat, outformat;
    int     sfsampsize;
    int     displays, graphsoff, postscript, msglevel;
    int     Beatmode, cmdTempo, oMaxLag;
    int     usingcscore, Linein;
    int     RTevents, Midiin, FMidiin, RMidiin;
    int     ringbell, termifend;
    int     rewrt_hdr, heartbeat, gen01defer;
    //    int     expr_opt;       /* IV - Jan 27 2005: for --expression-opt */
    float   sr_override, kr_override;
    int     nchnls_override, nchnls_i_override;
    char    *infilename, *outfilename;
    CORFIL  *playscore;
    char    *Linename, *Midiname, *FMidiname;
    char    *Midioutname;   /* jjk 09252000 - MIDI output device, -Q option */
    char    *FMidioutname;
    int     midiKey, midiKeyCps, midiKeyOct, midiKeyPch;
    int     midiVelocity, midiVelocityAmp;
    int     noDefaultPaths;  /* syy - Oct 25, 2006: for disabling relative paths
                                from files */
    int     numThreads;
    int     syntaxCheckOnly;
    int     useCsdLineCounts;
    int     sampleAccurate;  /* switch for score events sample accuracy */
    int     realtime; /* realtime priority mode  */
    MYFLT   e0dbfs_override;
    int     daemon;
    double  quality;        /* for ogg encoding */
    int     ksmps_override;
  } OPARMS;

  typedef struct arglst {
    int     count;
    char    *arg[1];
  } ARGLST;

  typedef struct arg {
    int type;
    void* argPtr;
    int index;
    struct arg* next;
  } ARG;
//  typedef struct argoffs {
//    int     count;
//    int     indx[1];
//  } ARGOFFS;

    typedef struct oentry {
        char    *opname;
        uint16  dsblksiz;
        uint16  flags;
        uint8_t thread;
        char    *outypes;
        char    *intypes;
        int     (*iopadr)(CSOUND *, void *p);
        int     (*kopadr)(CSOUND *, void *p);
        int     (*aopadr)(CSOUND *, void *p);
        void    *useropinfo;    /* user opcode parameters */
    } OENTRY;

    // holds matching oentries from opcodeList
    // has space for 16 matches and next pointer in case more are found
    // (unlikely though)
    typedef struct oentries {
        OENTRY* entries[16];
//        int opnum[16];
        int count;
        char *opname;
        int prvnum;
        struct oentries* next;
    } OENTRIES;

  /**
   * Storage for parsed orchestra code, for each opcode in an INSTRTXT.
   */
  typedef struct text {
    int             linenum;        /* Line num in orch file (currently buggy!)  */
    OENTRY          *oentry;
    char            *opcod;         /* Pointer to opcode name in global pool */
    ARGLST          *inlist;        /* Input args (pointer to item in name list) */
    ARGLST          *outlist;
    ARG             *inArgs;        /* Input args (index into list of values) */
    unsigned int    inArgCount;
    ARG             *outArgs;
    unsigned        int outArgCount;
    char            intype;         /* Type of first input argument (g,k,a,w etc) */
    char            pftype;         /* Type of output argument (k,a etc) */
  } TEXT;


  /**
   * This struct is filled out by otran() at orch parse time.
   * It is used as a template for instrument events.
   */
  typedef struct instr {
    struct op * nxtop;              /* Linked list of instr opcodes */
    TEXT    t;                      /* Text of instrument (same in nxtop) */
    int     pmax, vmax, pextrab;    /* Arg count, size of data for all
                                       opcodes in instr */
    int     mdepends;               /* Opcode type (i/k/a) */
    CS_VAR_POOL* varPool;

    //    int     optxtcount;
    int16   muted;
//    int32   localen;
    int32   opdstot;                /* Total size of opds structs in instr */
//    int32   *inslist;               /* Only used in parsing (?) */
    MYFLT   *psetdata;              /* Used for pset opcode */
    struct insds * instance;        /* Chain of allocated instances of
                                       this instrument */
    struct insds * lst_instance;    /* last allocated instance */
    struct insds * act_instance;    /* Chain of free (inactive) instances */
                                    /* (pointer to next one is INSDS.nxtact) */
    struct instr * nxtinstxt;       /* Next instrument in orch (num order) */
    int     active;                 /* To count activations for control */
    int     pending_release;        /* To count instruments in release phase */
    int     maxalloc;
    MYFLT   cpuload;                /* % load this instrumemnt makes */
    struct opcodinfo *opcode_info;  /* UDO info (when instrs are UDOs) */
    char    *insname;               /* instrument name */
    int     instcnt;                /* Count number of instances ever */
    int     isNew;                  /* is this a new definition */
    int     nocheckpcnt;            /* Control checks on pcnt */
  } INSTRTXT;

  typedef struct namedInstr {
    int32        instno;
    char        *name;
    INSTRTXT    *ip;
    struct namedInstr   *next;
  } INSTRNAME;

  /**
   * A chain of TEXT structs. Note that this is identical with the first two
   * members of struct INSTRTEXT, and is so typecast at various points in code.
   */
  typedef struct op {
    struct op *nxtop;
    TEXT    t;
  } OPTXT;

  typedef struct fdch {
    struct fdch *nxtchp;
    /** handle returned by csound->FileOpen() */
    void    *fd;
  } FDCH;

  typedef struct auxch {
    struct auxch *nxtchp;
    size_t  size;
    void    *auxp, *endp;
  } AUXCH;

  typedef struct {
    int      dimensions;
    int*     sizes;             /* size of each dimensions */
    int      arrayMemberSize;
    CS_TYPE* arrayType;
    MYFLT*   data;
//    AUXCH   aux;
  } ARRAYDAT;

   typedef struct {
      int     size;             /* 0...size-1 */
      MYFLT   *data;
      AUXCH   aux;
   } TABDAT;

  typedef struct {
    char *data;
    int size;
  } STRINGDAT;

  typedef struct monblk {
    int16   pch;
    struct monblk *prv;
  } MONPCH;

  typedef struct {
    int     notnum[4];
  } DPEXCL;

  typedef struct {
    DPEXCL  dpexcl[8];
    /** for keys 25-99 */
    int     exclset[75];
  } DPARM;

  typedef struct dklst {
    struct dklst *nxtlst;
    int32    pgmno;
    /** cnt + keynos */
    MYFLT   keylst[1];
  } DKLST;

  typedef struct mchnblk {
    /** most recently received program change */
    int16   pgmno;
    /** instrument number assigned to this channel */
    int16   insno;
    int16   RegParNo;
    int16   mono;
    MONPCH  *monobas;
    MONPCH  *monocur;
    /** list of active notes (NULL: not active) */
    struct insds *kinsptr[128];
    /** polyphonic pressure indexed by note number */
    MYFLT   polyaft[128];
    /** ... with GS vib_rate, stored in c128-c135 */
    MYFLT   ctl_val[136];
    /** program change to instr number (<=0: ignore) */
    int16   pgm2ins[128];
    /** channel pressure (0-127) */
    MYFLT   aftouch;
    /** pitch bend (-1 to 1) */
    MYFLT   pchbend;
    /** pitch bend sensitivity in semitones */
    MYFLT   pbensens;
    /** number of held (sustaining) notes */
    int16   ksuscnt;
    /** current state of sustain pedal (0: off) */
    int16   sustaining;
    int     dpmsb;
    int     dplsb;
    int     datenabl;
    /** chain of dpgm keylists */
    DKLST   *klists;
    /** drumset params         */
    DPARM   *dparms;
  } MCHNBLK;

  /**
   * This struct holds the data for one score event.
   */
  typedef struct event {
    /** String argument(s) (NULL if none) */
    int     scnt;
    char    *strarg;
    /* instance pointer */
    void  *pinstance;  /* TODO - Remove this field in Csound 7, not being used */
    /** Event type */
    char    opcod;
    /** Number of p-fields */
    int16   pcnt;
    /** Event start time */
    MYFLT   p2orig;
    /** Length */
    MYFLT   p3orig;
    /** All p-fields for this event (SSTRCOD: string argument) */
    MYFLT   p[PMAX + 1];
    union {                   /* To ensure size is same as earlier */
      MYFLT   *extra;
      MYFLT   p[2];
    } c;
  } EVTBLK;
  /**
   * This struct holds the info for a concrete instrument event
   * instance in performance.
   */
  typedef struct insds {
    /* Chain of init-time opcodes */
    struct opds * nxti;
    /* Chain of performance-time opcodes */
    struct opds * nxtp;
    /* Next allocated instance */
    struct insds * nxtinstance;
    /* Previous allocated instance */
    struct insds * prvinstance;
    /* Next in list of active instruments */
    struct insds * nxtact;
    /* Previous in list of active instruments */
    struct insds * prvact;
    /* Next instrument to terminate */
    struct insds * nxtoff;
    /* Chain of files used by opcodes in this instr */
    FDCH    *fdchp;
    /* Extra memory used by opcodes in this instr */
    AUXCH   *auxchp;
    /* Extra release time requested with xtratim opcode */
    int     xtratim;
    /* MIDI note info block if event started from MIDI */
    MCHNBLK *m_chnbp;
    /* ptr to next overlapping MIDI voice */
    struct insds * nxtolap;
    /* Instrument number */
    int16   insno;
    /* Instrument def address */
    INSTRTXT *instr;
    /* non-zero for sustaining MIDI note */
    int16   m_sust;
    /* MIDI pitch, for simple access */
    unsigned char m_pitch;
    /* ...ditto velocity */
    unsigned char m_veloc;
    /* Flag to indicate we are releasing, test with release opcode */
    char    relesing;
    /* Set if instr instance is active (perfing) */
    char    actflg;
    /* Time to turn off event, in score beats */
    double  offbet;
    /* Time to turn off event, in seconds (negative on indef/tie) */
    double  offtim;
    /* Python namespace for just this instance. */
    void    *pylocal;
    /* pointer to Csound engine and API for externals */
    CSOUND  *csound;
    int     kcounter;
    unsigned int     ksmps;     /* Instrument copy of ksmps */
    MYFLT   ekr;                /* and of rates */
    MYFLT   onedksmps, onedkr, kicvt;
    struct opds  *pds;          /* Used for jumping */
    MYFLT   scratchpad[4];      /* Persistent data */

    /* user defined opcode I/O buffers */
    void    *opcod_iobufs;
    void    *opcod_deact, *subins_deact;
    /* opcodes to be run at note deactivation */
    void    *nxtd;
    uint32_t ksmps_offset; /* ksmps offset for sample accuracy */
    uint32_t no_end;      /* samps left at the end for sample accuracy
                             (calculated) */
    uint32_t ksmps_no_end; /* samps left at the end for sample accuracy
                              (used by opcodes) */
    MYFLT  *spin;         /* offset into csound->spin */
    MYFLT  *spout;        /* offset into csound->spout, or local spout, if needed */
    int    init_done;
    int    tieflag;
    int    reinitflag;
    MYFLT  retval;
    MYFLT  *lclbas;  /* base for variable memory pool */
    char   *strarg;       /* string argument */
    /* Copy of required p-field values for quick access */
    CS_VAR_MEM  p0;
    CS_VAR_MEM  p1;
    CS_VAR_MEM  p2;
    CS_VAR_MEM  p3;
  } INSDS;

#define CS_KSMPS     (p->h.insdshead->ksmps)
#define CS_KCNT      (p->h.insdshead->kcounter)
#define CS_EKR       (p->h.insdshead->ekr)
#define CS_ONEDKSMPS (p->h.insdshead->onedksmps)
#define CS_ONEDKR    (p->h.insdshead->onedkr)
#define CS_KICVT     (p->h.insdshead->kicvt)
#define CS_ESR       (csound->esr)
#define CS_PDS       (p->h.insdshead->pds)
#define CS_SPIN      (p->h.insdshead->spin)
#define CS_SPOUT      (p->h.insdshead->spout)

  typedef int (*SUBR)(CSOUND *, void *);

  /**
   * This struct holds the info for one opcode in a concrete
   * instrument instance in performance.
   */
  typedef struct opds {
    /** Next opcode in init-time chain */
    struct opds * nxti;
    /** Next opcode in perf-time chain */
    struct opds * nxtp;
    /** Initialization (i-time) function pointer */
    SUBR    iopadr;
    /** Perf-time (k- or a-rate) function pointer */
    SUBR    opadr;
    /** Orch file template part for this opcode */
    OPTXT   *optext;
    /** Owner instrument instance data structure */
    INSDS   *insdshead;
  } OPDS;

  typedef struct lblblk {
    OPDS    h;
    OPDS    *prvi;
    OPDS    *prvp;
  } LBLBLK;

  typedef struct {
    MYFLT   *begp, *curp, *endp, feedback[6];
    int32    scount;
  } OCTDAT;

  typedef struct {
    int32    npts, nocts, nsamps;
    MYFLT   lofrq, hifrq, looct, srate;
    OCTDAT  octdata[MAXOCTS];
    AUXCH   auxch;
  } DOWNDAT;

  typedef struct {
    int32    ktimstamp, ktimprd;
    int32    npts, nfreqs, dbout;
    DOWNDAT *downsrcp;
    AUXCH   auxch;
  } SPECDAT;



  typedef struct {
    MYFLT   gen01;
    MYFLT   ifilno;
    MYFLT   iskptim;
    MYFLT   iformat;
    MYFLT   channel;
    MYFLT   sample_rate;
    char    strarg[SSTRSIZ];
  } GEN01ARGS;

  typedef struct {
    /** table length, not including the guard point */
    uint32_t flen;
    /** length mask ( = flen - 1) for power of two table size, 0 otherwise */
    int32    lenmask;
    /** log2(MAXLEN / flen) for power of two table size, 0 otherwise */
    int32    lobits;
    /** 2^lobits - 1 */
    int32    lomask;
    /** 1 / 2^lobits */
    MYFLT   lodiv;
    /** LOFACT * (table_sr / orch_sr), cpscvt = cvtbas / base_freq */
    MYFLT   cvtbas, cpscvt;
    /** sustain loop mode (0: none, 1: forward, 2: forward and backward) */
    int16   loopmode1;
    /** release loop mode (0: none, 1: forward, 2: forward and backward) */
    int16   loopmode2;
    /** sustain loop start and end in sample frames */
    int32    begin1, end1;
    /** release loop start and end in sample frames */
    int32    begin2, end2;
    /** sound file length in sample frames (flenfrms = soundend - 1) */
    int32    soundend, flenfrms;
    /** number of channels */
    int32    nchanls;
    /** table number */
    int32    fno;
    /** args  */
    MYFLT args[PMAX - 4];
    /** arg count */
    int argcnt;
    /** GEN01 parameters */
    GEN01ARGS gen01args;
    /** table data (flen + 1 MYFLT values) */
    MYFLT   *ftable;
  } FUNC;

  typedef struct {
    CSOUND  *csound;
    int32   flen;
    int     fno, guardreq;
    EVTBLK  e;
  } FGDATA;

  typedef struct {
    char    *name;
    int     (*fn)(FGDATA *, FUNC *);
  } NGFENS;

  typedef int (*GEN)(FGDATA *, FUNC *);

  typedef struct MEMFIL {
    char    filename[256];      /* Made larger RWD */
    char    *beginp;
    char    *endp;
    int32    length;
    struct MEMFIL *next;
  } MEMFIL;

  typedef struct {
    int16   type;
    int16   chan;
    int16   dat1;
    int16   dat2;
  } MEVENT;

  typedef struct SNDMEMFILE_ {
    /** file ID (short name)          */
    char            *name;
    struct SNDMEMFILE_ *nxt;
    /** full path filename            */
    char            *fullName;
    /** file length in sample frames  */
    size_t          nFrames;
    /** sample rate in Hz             */
    double          sampleRate;
    /** number of channels            */
    int             nChannels;
    /** AE_SHORT, AE_FLOAT, etc.      */
    int             sampleFormat;
    /** TYP_WAV, TYP_AIFF, etc.       */
    int             fileType;
    /**
     * loop mode:
     *   0: no loop information
     *   1: off
     *   2: forward
     *   3: backward
     *   4: bidirectional
     */
    int             loopMode;
    /** playback start offset frames  */
    double          startOffs;
    /** loop start (sample frames)    */
    double          loopStart;
    /** loop end (sample frames)      */
    double          loopEnd;
    /** base frequency (in Hz)        */
    double          baseFreq;
    /** amplitude scale factor        */
    double          scaleFac;
    /** interleaved sample data       */
    float           data[1];
  } SNDMEMFILE;

  typedef struct pvx_memfile_ {
    char        *filename;
    struct pvx_memfile_ *nxt;
    float       *data;
    uint32 nframes;
    int         format;
    int         fftsize;
    int         overlap;
    int         winsize;
    int         wintype;
    int         chans;
    MYFLT       srate;
  } PVOCEX_MEMFILE;

#ifdef __BUILDING_LIBCSOUND

#define INSTR   1
#define ENDIN   2
#define OPCODE  3
#define ENDOP   4
#define LABEL   5
#define SETBEG  6
#define PSET    6
#define USEROPCODE    7
#define SETEND  8

#define TOKMAX  50L     /* Should be 50 but bust */

/* max number of input/output args for user defined opcodes */
#define OPCODENUMOUTS_LOW   16
#define OPCODENUMOUTS_HIGH  64
#define OPCODENUMOUTS_MAX   256

#define MBUFSIZ         (4096)
#define MIDIINBUFMAX    (1024)
#define MIDIINBUFMSK    (MIDIINBUFMAX-1)



  typedef union {
    uint32 dwData;
    unsigned char bData[4];
  } MIDIMESSAGE;

  /* MIDI globals */

  typedef struct midiglobals {
    MEVENT  *Midevtblk;
    int     sexp;
    int     MIDIoutDONE;
    int     MIDIINbufIndex;
    MIDIMESSAGE MIDIINbuffer2[MIDIINBUFMAX];
    int     (*MidiInOpenCallback)(CSOUND *, void **, const char *);
    int     (*MidiReadCallback)(CSOUND *, void *, unsigned char *, int);
    int     (*MidiInCloseCallback)(CSOUND *, void *);
    int     (*MidiOutOpenCallback)(CSOUND *, void **, const char *);
    int     (*MidiWriteCallback)(CSOUND *, void *, const unsigned char *, int);
    int     (*MidiOutCloseCallback)(CSOUND *, void *);
    const char *(*MidiErrorStringCallback)(int);
    void    *midiInUserData;
    void    *midiOutUserData;
    void    *midiFileData;
    void    *midiOutFileData;
    int     rawControllerMode;
    char    muteTrackList[256];
    unsigned char mbuf[MBUFSIZ];
    unsigned char *bufp, *endatp;
    int16   datreq, datcnt;
  } MGLOBAL;

  typedef struct eventnode {
    struct eventnode  *nxt;
    uint32     start_kcnt;
    EVTBLK            evt;
  } EVTNODE;

  typedef struct {
    OPDS    h;
    MYFLT   *ktempo, *istartempo;
    MYFLT   prvtempo;
  } TEMPO;

  /* typedef struct token { */
  /*   char    *str; */
  /*   int16   prec; */
  /* } TOKEN; */

  typedef struct names {
    char    *mac;
    struct names *next;
  } NAMES;

  typedef struct threadInfo {
    struct threadInfo *next;
    void * threadId;
  } THREADINFO;

#include "sort.h"
#include "text.h"
#include "prototyp.h"
#include "cwindow.h"
#include "envvar.h"
#include "remote.h"

#define CS_STATE_PRE    (1)
#define CS_STATE_COMP   (2)
#define CS_STATE_UTIL   (4)
#define CS_STATE_CLN    (8)
#define CS_STATE_JMP    (16)

/* These are used to set/clear bits in csound->tempStatus.
   If the bit is set, it indicates that the given file is
   a temporary. */
  extern const uint32_t csOrcMask;
  extern const uint32_t csScoInMask;
  extern const uint32_t csScoSortMask;
  extern const uint32_t csMidiScoMask;
  extern const uint32_t csPlayScoMask;

/* kperf function protoypes. Used by the debugger to switch between debug
 * and nodebug kperf functions */
  int kperf_nodebug(CSOUND *csound);
  int kperf_debug(CSOUND *csound);

#endif  /* __BUILDING_LIBCSOUND */

#define MARGS   (3)
typedef struct S_MACRO {          /* To store active macros */
    char        *name;          /* Use is by name */
    int         acnt;           /* Count of arguments */
    CORFIL      *body;          /* The text of the macro */
    struct S_MACRO *next;         /* Chain of active macros */
    int         margs;          /* ammount of space for args */
    char        *arg[MARGS];    /* With these arguments */
} S_MACRO;

typedef struct in_stack_s {     /* Stack of active inputs */
    int16       is_marked_repeat;     /* 1 if this input created by 'n' stmnt */
    int16       args;                 /* Argument count for macro */
    CORFIL      *cf;                  /* In core file */
    void        *fd;                  /* for closing stream */
    S_MACRO       *mac;
    int         line;
} IN_STACK;

typedef struct marked_sections {
    char        *name;
    int32       posit;
    int         line;
    char        *file;
} MARKED_SECTIONS;

typedef struct namelst {
  char           *name;
  struct namelst *next;
} NAMELST;

typedef struct NAME__ {
    char          *namep;
    struct NAME__  *nxt;
    int           type, count;
} NAME;

  /* Holds UDO information, when an instrument is
     defined as a UDO
  */
  typedef struct opcodinfo {
    int32    instno;
    char    *name, *intypes, *outtypes;
    int16   inchns, outchns;
    CS_VAR_POOL* out_arg_pool;
    CS_VAR_POOL* in_arg_pool;
    INSTRTXT *ip;
    struct opcodinfo *prv;
  } OPCODINFO;

  /**
   * This struct will hold the current engine state after compilation
   */
  typedef struct engine_state {
    CS_VAR_POOL    *varPool;  /* global variable pool */
    MYFLT_POOL*   constantsPool;
    CS_HASH_TABLE*  stringPool;
    int            maxopcno;
    INSTRTXT      **instrtxtp; /* instrument list      */
    INSTRTXT      instxtanchor;
    CS_HASH_TABLE *instrumentNames; /* instrument names */
    int           maxinsno;
  } ENGINE_STATE;


  /**
   * plugin module info
   */
  typedef struct {
    char module[12];
    char type[12];
  } MODULE_INFO;

  /**
   * Contains all function pointers, data, and data pointers required
   * to run one instance of Csound.
   *
   * \b PUBLIC functions in CSOUND_
   * These are used by plugins to access the
   * Csound library functionality without the requirement
   * of compile-time linkage to the csound library
   * New functions only need to be added here if
   * they are required by plugins.
   */
  struct CSOUND_ {

    /** @name Attributes */
    /**@{ */
    MYFLT (*GetSr)(CSOUND *);
    MYFLT (*GetKr)(CSOUND *);
    uint32_t (*GetKsmps)(CSOUND *);
     /** Get number of output channels */
    uint32_t (*GetNchnls)(CSOUND *);
    /** Get number of input channels */
    uint32_t (*GetNchnls_i)(CSOUND *);
    MYFLT (*Get0dBFS) (CSOUND *);
    /** Get number of control blocks elapsed */
    long (*GetKcounter)(CSOUND *);
    int64_t (*GetCurrentTimeSamples)(CSOUND *);
    long (*GetInputBufferSize)(CSOUND *);
    long (*GetOutputBufferSize)(CSOUND *);
    MYFLT *(*GetInputBuffer)(CSOUND *);
    MYFLT *(*GetOutputBuffer)(CSOUND *);
    /** Set internal debug mode */
    void (*SetDebug)(CSOUND *, int d);
    int (*GetDebug)(CSOUND *);
    int (*GetSizeOfMYFLT)(void);
    void (*GetOParms)(CSOUND *, OPARMS *);
    /** Get environment variable */
    const char *(*GetEnv)(CSOUND *, const char *name);
    /**@}*/
    /** @name Message printout */
    /**@{ */
    CS_PRINTF2 void (*Message)(CSOUND *, const char *fmt, ...);
    CS_PRINTF3 void (*MessageS)(CSOUND *, int attr, const char *fmt, ...);
    void (*MessageV)(CSOUND *, int attr, const char *format, va_list args);
    int (*GetMessageLevel)(CSOUND *);
    void (*SetMessageLevel)(CSOUND *, int messageLevel);
    void (*SetMessageCallback)(CSOUND *,
                void (*csoundMessageCallback)(CSOUND *,
                                              int attr, const char *format,
                                              va_list valist));
    /**@}*/
    /** @name Event and MIDI functionality for opcodes */
    /**@{ */
    int (*SetReleaseLength)(void *p, int n);
    MYFLT (*SetReleaseLengthSeconds)(void *p, MYFLT n);
    int (*GetMidiChannelNumber)(void *p);
    MCHNBLK *(*GetMidiChannel)(void *p);
    int (*GetMidiNoteNumber)(void *p);
    int (*GetMidiVelocity)(void *p);
    int (*GetReleaseFlag)(void *p);
    double (*GetOffTime)(void *p);
    MYFLT *(*GetPFields)(void *p);
    int (*GetInstrumentNumber)(void *p);
    int (*GetZakBounds)(CSOUND *, MYFLT **);
    int (*GetTieFlag)(CSOUND *);
    int (*GetReinitFlag)(CSOUND *);
    /** Current maximum number of strings, accessible through the strset
        and strget opcodes */
    int (*GetStrsmax)(CSOUND *);
    char *(*GetStrsets)(CSOUND *, long);
    /* Fast power of two function from a precomputed table */
    MYFLT (*Pow2)(CSOUND *, MYFLT a);
    /* Fast power function for positive integers */
    MYFLT (*intpow)(MYFLT, int32);
    /* Returns a string name for the file type */
    char *(*type2string)(int type);
    /**@}*/
    /** @name Arguments to opcodes */
    /**@{ */
    CS_TYPE *(*GetTypeForArg)(void *p);
    int (*GetInputArgCnt)(void *p);
    char *(*GetInputArgName)(void *p, int n);
    int (*GetOutputArgCnt)(void *p);
    char *(*GetOutputArgName)(void *p, int n);
    char *(*GetString)(CSOUND *, MYFLT);
    int32 (*strarg2insno)(CSOUND *, void *p, int is_string);
    char *(*strarg2name)(CSOUND *, char *, void *, const char *, int);

    /**@}*/
    /** @name Memory allocation */
    /**@{ */
    void (*AuxAlloc)(CSOUND *, size_t nbytes, AUXCH *auxchp);
    void *(*Malloc)(CSOUND *, size_t nbytes);
    void *(*Calloc)(CSOUND *, size_t nbytes);
    void *(*ReAlloc)(CSOUND *, void *oldp, size_t nbytes);
    char *(*Strdup)(CSOUND *, char*);
    void (*Free)(CSOUND *, void *ptr);

    /**@}*/
    /** @name Function tables */
    /**@{ */
    int (*hfgens)(CSOUND *, FUNC **, const EVTBLK *, int);
    int (*FTAlloc)(CSOUND *, int tableNum, int len);
    int (*FTDelete)(CSOUND *, int tableNum);
    /** Find tables with power of two size. If table exists but is
        not a power of 2, NULL is returned. */
    FUNC *(*FTFind)(CSOUND *, MYFLT *argp);
    /** Find any table, except deferred load tables. */
    FUNC *(*FTFindP)(CSOUND *, MYFLT *argp);
    /** Find any table. */
    FUNC *(*FTnp2Find)(CSOUND *, MYFLT *argp);
    int (*GetTable)(CSOUND *, MYFLT **tablePtr, int tableNum);
    int (*TableLength)(CSOUND *, int table);
    MYFLT (*TableGet)(CSOUND *, int table, int index);
    void (*TableSet)(CSOUND *, int table, int index, MYFLT value);
    void *(*GetNamedGens)(CSOUND *);

    /**@}*/
    /** @name Global and config variable manipulation */
    /**@{ */
    int (*CreateGlobalVariable)(CSOUND *, const char *name, size_t nbytes);
    void *(*QueryGlobalVariable)(CSOUND *, const char *name);
    void *(*QueryGlobalVariableNoCheck)(CSOUND *, const char *name);
    int (*DestroyGlobalVariable)(CSOUND *, const char *name);
    int (*CreateConfigurationVariable)(CSOUND *, const char *name,
                                       void *p, int type, int flags,
                                       void *min, void *max,
                                       const char *shortDesc,
                                       const char *longDesc);
    int (*SetConfigurationVariable)(CSOUND *, const char *name, void *value);
    int (*ParseConfigurationVariable)(CSOUND *,
                                      const char *name, const char *value);
    csCfgVariable_t *(*QueryConfigurationVariable)(CSOUND *, const char *name);
    csCfgVariable_t **(*ListConfigurationVariables)(CSOUND *);
    int (*DeleteConfigurationVariable)(CSOUND *, const char *name);
    const char *(*CfgErrorCodeToString)(int errcode);

    /**@}*/
    /** @name FFT support */
    /**@{ */
    MYFLT (*GetInverseComplexFFTScale)(CSOUND *, int FFTsize);
    MYFLT (*GetInverseRealFFTScale)(CSOUND *, int FFTsize);
    void (*ComplexFFT)(CSOUND *, MYFLT *buf, int FFTsize);
    void (*InverseComplexFFT)(CSOUND *, MYFLT *buf, int FFTsize);
    void (*RealFFT)(CSOUND *, MYFLT *buf, int FFTsize);
    void (*InverseRealFFT)(CSOUND *, MYFLT *buf, int FFTsize);
    void (*RealFFTMult)(CSOUND *, MYFLT *outbuf, MYFLT *buf1, MYFLT *buf2,
                                  int FFTsize, MYFLT scaleFac);
    void (*RealFFTnp2)(CSOUND *, MYFLT *buf, int FFTsize);
    void (*InverseRealFFTnp2)(CSOUND *, MYFLT *buf, int FFTsize);

    /**@}*/
    /** @name PVOC-EX system */
    /**@{ */
    int (*PVOC_CreateFile)(CSOUND *, const char *,
                           uint32, uint32, uint32,
                           uint32, int32, int, int,
                           float, float *, uint32);
    int (*PVOC_OpenFile)(CSOUND *, const char *, void  *, void *);
    int (*PVOC_CloseFile)(CSOUND *, int);
    int (*PVOC_PutFrames)(CSOUND *, int, const float *, int32);
    int (*PVOC_GetFrames)(CSOUND *, int, float *, uint32);
    int (*PVOC_FrameCount)(CSOUND *, int);
    int (*PVOC_fseek)(CSOUND *, int, int);
    const char *(*PVOC_ErrorString)(CSOUND *);
    int (*PVOCEX_LoadFile)(CSOUND *, const char *, PVOCEX_MEMFILE *);

    /**@}*/
    /** @name Error messages */
    /**@{ */
    CS_NORETURN CS_PRINTF2 void (*Die)(CSOUND *, const char *msg, ...);
    CS_PRINTF2 int (*InitError)(CSOUND *, const char *msg, ...);
    CS_PRINTF3 int (*PerfError)(CSOUND *, INSDS *ip,  const char *msg, ...);
    CS_PRINTF2 void (*Warning)(CSOUND *, const char *msg, ...);
    CS_PRINTF2 void (*DebugMsg)(CSOUND *, const char *msg, ...);
    CS_NORETURN void (*LongJmp)(CSOUND *, int);
    CS_PRINTF2 void (*ErrorMsg)(CSOUND *, const char *fmt, ...);
    void (*ErrMsgV)(CSOUND *, const char *hdr, const char *fmt, va_list);

    /**@}*/
    /** @name Random numbers */
    /**@{ */
    uint32_t (*GetRandomSeedFromTime)(void);
    void (*SeedRandMT)(CsoundRandMTState *p,
                       const uint32_t *initKey, uint32_t keyLength);
    uint32_t (*RandMT)(CsoundRandMTState *p);
    int (*Rand31)(int *seedVal);
    int (*GetRandSeed)(CSOUND *, int which);

    /**@}*/
    /** @name Threads and locks */
    /**@{ */
    void *(*CreateThread)(uintptr_t (*threadRoutine)(void *), void *userdata);
    uintptr_t (*JoinThread)(void *thread);
    void *(*CreateThreadLock)(void);
    void (*DestroyThreadLock)(void *lock);
    int (*WaitThreadLock)(void *lock, size_t milliseconds);
    void (*NotifyThreadLock)(void *lock);
    void (*WaitThreadLockNoTimeout)(void *lock);
    void *(*Create_Mutex)(int isRecursive);
    int (*LockMutexNoWait)(void *mutex_);
    void (*LockMutex)(void *mutex_);
    void (*UnlockMutex)(void *mutex_);
    void (*DestroyMutex)(void *mutex_);
    void *(*CreateBarrier)(unsigned int max);
    int (*DestroyBarrier)(void *);
    int (*WaitBarrier)(void *);
    void *(*GetCurrentThreadID)(void);
    void (*Sleep)(size_t milliseconds);
    void (*InitTimerStruct)(RTCLOCK *);
    double (*GetRealTime)(RTCLOCK *);
    double (*GetCPUTime)(RTCLOCK *);

    /**@}*/
    /** @name Circular lock-free buffer */
    /**@{ */
    void *(*CreateCircularBuffer)(CSOUND *, int, int);
    int (*ReadCircularBuffer)(CSOUND *, void *, void *, int);
    int (*WriteCircularBuffer)(CSOUND *, void *, const void *, int);
    void (*FlushCircularBuffer)(CSOUND *, void *);
    void (*DestroyCircularBuffer)(CSOUND *, void *);

    /**@}*/
    /** @name File access */
    /**@{ */
    char *(*FindInputFile)(CSOUND *, const char *filename, const char *envList);
    char *(*FindOutputFile)(CSOUND *,
                            const char *filename, const char *envList);
    void *(*SAsndgetset)(CSOUND *,
                         char *, void *, MYFLT *, MYFLT *, MYFLT *, int);
    void *(*sndgetset)(CSOUND *, void *);
    int (*getsndin)(CSOUND *, void *, MYFLT *, int, void *);
    void (*rewriteheader)(void *ofd);
    SNDMEMFILE *(*LoadSoundFile)(CSOUND *, const char *, void *);
    void (*FDRecord)(CSOUND *, FDCH *fdchp);
    void (*FDClose)(CSOUND *, FDCH *fdchp);
    void *(*CreateFileHandle)(CSOUND *, void *, int, const char *);
    char *(*GetFileName)(void *);
    int (*FileClose)(CSOUND *, void *);
    void *(*FileOpen2)(CSOUND *, void *, int, const char *, void *,
                      const char *, int, int);
    int (*type2csfiletype)(int type, int encoding);
    void (*NotifyFileOpened)(CSOUND*, const char*, int, int, int);
    int (*sftype2csfiletype)(int type);
    MEMFIL *(*ldmemfile2withCB)(CSOUND *, const char *, int,
                                int (*callback)(CSOUND *, MEMFIL *));
    void *(*FileOpenAsync)(CSOUND *, void *, int, const char *, void *,
                           const char *, int, int, int);
    unsigned int (*ReadAsync)(CSOUND *, void *, MYFLT *, int);
    unsigned int (*WriteAsync)(CSOUND *, void *, MYFLT *, int);
    int  (*FSeekAsync)(CSOUND *, void *, int, int);
    char *(*getstrformat)(int format);
    int (*sfsampsize)(int format);

    /**@}*/
    /** @name RT audio IO and callbacks */
    /**@{ */
    void (*SetPlayopenCallback)(CSOUND *,
                int (*playopen__)(CSOUND *, const csRtAudioParams *parm));
    void (*SetRtplayCallback)(CSOUND *,
                void (*rtplay__)(CSOUND *, const MYFLT *outBuf, int nbytes));
    void (*SetRecopenCallback)(CSOUND *,
                int (*recopen__)(CSOUND *, const csRtAudioParams *parm));
    void (*SetRtrecordCallback)(CSOUND *,
                int (*rtrecord__)(CSOUND *, MYFLT *inBuf, int nbytes));
    void (*SetRtcloseCallback)(CSOUND *, void (*rtclose__)(CSOUND *));
    void (*SetAudioDeviceListCallback)(CSOUND *csound,
          int (*audiodevlist__)(CSOUND *, CS_AUDIODEVICE *list, int isOutput));
    void **(*GetRtRecordUserData)(CSOUND *);
    void **(*GetRtPlayUserData)(CSOUND *);
    int (*GetDitherMode)(CSOUND *);
    /**@}*/
    /** @name RT MIDI and callbacks */
    /**@{ */
    void (*SetExternalMidiInOpenCallback)(CSOUND *,
                int (*func)(CSOUND *, void **, const char *));
    void (*SetExternalMidiReadCallback)(CSOUND *,
                int (*func)(CSOUND *, void *, unsigned char *, int));
    void (*SetExternalMidiInCloseCallback)(CSOUND *,
                int (*func)(CSOUND *, void *));
    void (*SetExternalMidiOutOpenCallback)(CSOUND *,
                int (*func)(CSOUND *, void **, const char *));
    void (*SetExternalMidiWriteCallback)(CSOUND *,
                int (*func)(CSOUND *, void *, const unsigned char *, int));
    void (*SetExternalMidiOutCloseCallback)(CSOUND *,
                int (*func)(CSOUND *, void *));
    void (*SetExternalMidiErrorStringCallback)(CSOUND *,
                const char *(*func)(int));
    void (*SetMIDIDeviceListCallback)(CSOUND *csound,
          int (*audiodevlist__)(CSOUND *, CS_MIDIDEVICE *list, int isOutput));
    void (*module_list_add)(CSOUND *, char *, char *);
    /**@}*/
    /** @name Displays & graphs */
    /**@{ */
    void (*dispset)(CSOUND *, WINDAT *, MYFLT *, int32, char *, int, char *);
    void (*display)(CSOUND *, WINDAT *);
    int (*dispexit)(CSOUND *);
    void (*dispinit)(CSOUND *);
    int (*SetIsGraphable)(CSOUND *, int isGraphable);
    void (*SetMakeGraphCallback)(CSOUND *,
                void (*makeGraphCallback)(CSOUND *, WINDAT *p,
                                                    const char *name));
    void (*SetDrawGraphCallback)(CSOUND *,
                void (*drawGraphCallback)(CSOUND *, WINDAT *p));
    void (*SetKillGraphCallback)(CSOUND *,
                void (*killGraphCallback)(CSOUND *, WINDAT *p));
    void (*SetExitGraphCallback)(CSOUND *, int (*exitGraphCallback)(CSOUND *));
    /**@}*/
    /** @name Generic callbacks */
    /**@{ */
    void (*SetYieldCallback)(CSOUND *, int (*yieldCallback)(CSOUND *));
    int (*Set_KeyCallback)(CSOUND *, int (*func)(void *, void *, unsigned int),
                        void *userData, unsigned int typeMask);
    void (*Remove_KeyCallback)(CSOUND *,
                            int (*func)(void *, void *, unsigned int));
    int (*RegisterSenseEventCallback)(CSOUND *, void (*func)(CSOUND *, void *),
                                                void *userData);
    int (*RegisterDeinitCallback)(CSOUND *, void *p,
                                            int (*func)(CSOUND *, void *));
    int (*RegisterResetCallback)(CSOUND *, void *userData,
                                           int (*func)(CSOUND *, void *));
    void (*SetInternalYieldCallback)(CSOUND *,
                       int (*yieldCallback)(CSOUND *));
    /**@}*/
    /** @name Opcodes and instruments */
    /**@{ */
    int (*AppendOpcode)(CSOUND *, const char *opname, int dsblksiz, int flags,
                        int thread, const char *outypes, const char *intypes,
                        int (*iopadr)(CSOUND *, void *),
                        int (*kopadr)(CSOUND *, void *),
                        int (*aopadr)(CSOUND *, void *));
    int (*AppendOpcodes)(CSOUND *, const OENTRY *opcodeList, int n);
    char *(*GetOpcodeName)(void *p);
    INSTRTXT **(*GetInstrumentList)(CSOUND *);
    /**@}*/
    /** @name Events and performance */
    /**@{ */
    int (*CheckEvents)(CSOUND *);
    int (*insert_score_event)(CSOUND *, EVTBLK *, double);
    int (*insert_score_event_at_sample)(CSOUND *, EVTBLK *, int64_t);
    int (*PerformKsmps)(CSOUND *);
    /**@}*/
    /** @name Utilities */
    /**@{ */
    int (*AddUtility)(CSOUND *, const char *name,
                      int (*UtilFunc)(CSOUND *, int, char **));
    int (*RunUtility)(CSOUND *, const char *name, int argc, char **argv);
    char **(*ListUtilities)(CSOUND *);
    int (*SetUtilityDescription)(CSOUND *, const char *utilName,
                                           const char *utilDesc);
    const char *(*GetUtilityDescription)(CSOUND *, const char *utilName);
    void (*SetUtilSr)(CSOUND *, MYFLT);
    void (*SetUtilNchnls)(CSOUND *, int);
    /**@}*/
    /** @name Miscellaneous */
    /**@{ */
    long (*RunCommand)(const char * const *argv, int noWait);
    int (*OpenLibrary)(void **library, const char *libraryPath);
    int (*CloseLibrary)(void *library);
    void *(*GetLibrarySymbol)(void *library, const char *procedureName);
#ifndef __MACH__
    char *(*LocalizeString)(const char *) __attribute__ ((format_arg (1)));
#else
    char *(*LocalizeString)(const char *);
#endif
    char *(*strtok_r)(char*, char*, char**);
    double (*strtod)(char*, char**);
    int (*sprintf)(char *str, const char *format, ...);
    int (*sscanf)(char *str, const char *format, ...);
    MYFLT (*system_sr)(CSOUND *, MYFLT );
    /**@}*/
    /** @name Score Event s*/
    /**@{ */
    MYFLT (*GetScoreOffsetSeconds)(CSOUND *);
    void (*SetScoreOffsetSeconds)(CSOUND *, MYFLT offset);
    void (*RewindScore)(CSOUND *);
    void (*InputMessage)(CSOUND *, const char *message__);
       /**@}*/
    /** @name Placeholders
        To allow the API to grow while maintining backward binary compatibility. */
    /**@{ */
    SUBR dummyfn_2[43];
    /**@}*/
#ifdef __BUILDING_LIBCSOUND
    /* ------- private data (not to be used by hosts or externals) ------- */
    /** @name Private Data
      Private Data in the CSOUND struct to be used internally by the Csound
      library and should be hidden from plugins.
      If a new variable member is needed by the library, add it below, as a
      private data member. If access is required solely by plugins (and not
      internally by the library), use the CreateGlobalVariable() etc. interface,
      instead of adding to CSOUND.

      If you find that a plugin needs to access existing private data,
      first check above for an existing interface; if none is available,
      add one. Please avoid giving full access, or allowing plugins to
      change the values of private members, by using one of the two methods
      below:

      1) To get the data member value:
      \code
         returnType (*GetVar)(CSOUND *)
      \endcode
      2) in case of pointers, data should be copied out to a supplied memory
         slot, rather than the pointer being obtained:
      \code
         void (*GetData)(CSOUND *, dataType *)

         dataType var;
         csound->GetData(csound, &var);
      \endcode
    */
    /**@{ */
    SUBR          first_callback_;
    channelCallback_t InputChannelCallback_;
    channelCallback_t OutputChannelCallback_;
    void          (*csoundMessageCallback_)(CSOUND *, int attr,
                                            const char *format, va_list args);
    int           (*csoundConfigureCallback_)(CSOUND *);
    void          (*csoundMakeGraphCallback_)(CSOUND *, WINDAT *windat,
                                                        const char *name);
    void          (*csoundDrawGraphCallback_)(CSOUND *, WINDAT *windat);
    void          (*csoundKillGraphCallback_)(CSOUND *, WINDAT *windat);
    int           (*csoundExitGraphCallback_)(CSOUND *);
    int           (*csoundYieldCallback_)(CSOUND *);
    void          (*cscoreCallback_)(CSOUND *);
    void          (*FileOpenCallback_)(CSOUND*, const char*, int, int, int);
    SUBR          last_callback_;
    /* these are not saved on RESET */
    int           (*playopen_callback)(CSOUND *, const csRtAudioParams *parm);
    void          (*rtplay_callback)(CSOUND *, const MYFLT *outBuf, int nbytes);
    int           (*recopen_callback)(CSOUND *, const csRtAudioParams *parm);
    int           (*rtrecord_callback)(CSOUND *, MYFLT *inBuf, int nbytes);
    void          (*rtclose_callback)(CSOUND *);
    int           (*audio_dev_list_callback)(CSOUND *, CS_AUDIODEVICE *, int);
    int           (*midi_dev_list_callback)(CSOUND *, CS_MIDIDEVICE *, int);
    int           (*doCsoundCallback)(CSOUND *, void *, unsigned int);
    int           (*csoundInternalYieldCallback_)(CSOUND *);
    /* end of callbacks */
    void          (*spinrecv)(CSOUND *);
    void          (*spoutran)(CSOUND *);
    int           (*audrecv)(CSOUND *, MYFLT *, int);
    void          (*audtran)(CSOUND *, const MYFLT *, int);
    void          *hostdata;
    char          *orchname, *scorename;
    CORFIL        *orchstr, *scorestr;
    OPDS          *ids;             /* used by init loops */
    ENGINE_STATE  engineState;      /* current Engine State merged after
                                       compilation */
    INSTRTXT      *instr0;          /* instr0     */
    INSTRTXT      **dead_instr_pool;
    int           dead_instr_no;
    TYPE_POOL*    typePool;
    unsigned int  ksmps;
    uint32_t      nchnls;
    int           inchnls;
    int           spoutactive;
    long          kcounter, global_kcounter;
    MYFLT         esr;
    MYFLT         ekr;
    /** current time in seconds, inc. per kprd */
    int64_t       icurTime;   /* Current time in samples */
    double        curTime_inc;
    /** start time of current section    */
    double        timeOffs, beatOffs;
    /** current time in beats, inc per kprd */
    double        curBeat, curBeat_inc;
    /** beat time = 60 / tempo           */
    int64_t       ibeatTime;   /* Beat time in samples */
    EVTBLK        *currevent;
    INSDS         *curip;
    MYFLT         cpu_power_busy;
    char          *xfilename;
    int           peakchunks;
    int           keep_tmp;
    CS_HASH_TABLE *opcodes;
    int32         nrecs;
    FILE*         Linepipe;
    int           Linefd;
    void          *csoundCallbacks_;
    FILE*         scfp;
    CORFIL        *scstr;
    FILE*         oscfp;
    MYFLT         maxamp[MAXCHNLS];
    MYFLT         smaxamp[MAXCHNLS];
    MYFLT         omaxamp[MAXCHNLS];
    uint32        maxpos[MAXCHNLS], smaxpos[MAXCHNLS], omaxpos[MAXCHNLS];
    FILE*         scorein;
    FILE*         scoreout;
    int           *argoffspace;
    INSDS         *frstoff;
    MYFLT         *zkstart;
    long          zklast;
    MYFLT         *zastart;
    long          zalast;
    /** reserved for std opcode library  */
    void          *stdOp_Env;
    int           holdrand;
    int           randSeed1;
    int           randSeed2;
    CsoundRandMTState *csRandState;
    RTCLOCK       *csRtClock;
    int           strsmax;
    char          **strsets;
    MYFLT         *spin;
    MYFLT         *spout;
    int           nspin;
    int           nspout;
    MYFLT         *auxspin;
    OPARMS        *oparms;
    /** reserve space for up to 4 MIDI devices */
    MCHNBLK       *m_chnbp[64];
    int           dither_output;
    MYFLT         onedsr, sicvt;
    MYFLT         tpidsr, pidsr, mpidsr, mtpdsr;
    MYFLT         onedksmps;
    MYFLT         onedkr;
    MYFLT         kicvt;
    int           reinitflag;
    int           tieflag;
    MYFLT         e0dbfs, dbfs_to_float;
    void          *rtRecord_userdata;
    void          *rtPlay_userdata;
    jmp_buf       exitjmp;
    SRTBLK        *frstbp;
    int           sectcnt;
    int           inerrcnt, synterrcnt, perferrcnt;
    INSDS         actanchor;
    int32         rngcnt[MAXCHNLS];
    int16         rngflg, multichan;
    void          *evtFuncChain;
    EVTNODE       *OrcTrigEvts;             /* List of events to be started */
    EVTNODE       *freeEvtNodes;
    int           csoundIsScorePending_;
    int64_t       advanceCnt;
    int           initonly;
    int           evt_poll_cnt;
    int           evt_poll_maxcnt;
    int           Mforcdecs, Mxtroffs, MTrkend;
    OPCODINFO     *opcodeInfo;
    FUNC**        flist;
    int           maxfnum;
    GEN           *gensub;
    int           genmax;
    CS_HASH_TABLE *namedGlobals;
    CS_HASH_TABLE *cfgVariableDB;
    double        prvbt, curbt, nxtbt;
    double        curp2, nxtim;
    int64_t       cyclesRemaining;
    EVTBLK        evt;
    void          *memalloc_db;
    MGLOBAL       *midiGlobals;
    CS_HASH_TABLE *envVarDB;
    MEMFIL        *memfiles;
    PVOCEX_MEMFILE *pvx_memfiles;
    int           FFT_max_size;
    void          *FFT_table_1;
    void          *FFT_table_2;
    /* statics from twarp.c should be TSEG* */
    void          *tseg, *tpsave, *tplim;
    /* Statics from express.c */
    MYFLT         *gbloffbas;       /* was static in oload.c */
    pthread_t    file_io_thread;
    int          file_io_start;
    void         *file_io_threadlock;
    int          realtime_audio_flag;
    pthread_t    init_pass_thread;
    int          init_pass_loop;
    void         *init_pass_threadlock;
    void         *API_lock;
    #if defined(HAVE_PTHREAD_SPIN_LOCK)
    pthread_spinlock_t spoutlock, spinlock;
#else
    int           spoutlock, spinlock;
#endif /* defined(HAVE_PTHREAD_SPIN_LOCK) */
#if defined(HAVE_PTHREAD_SPIN_LOCK)
    pthread_spinlock_t memlock, spinlock1;
#else
    int           memlock, spinlock1;
#endif /* defined(HAVE_PTHREAD_SPIN_LOCK) */
    char          *delayederrormessages;
    void          *printerrormessagesflag;
    struct sreadStatics__ {
      SRTBLK  *bp, *prvibp;           /* current srtblk,  prev w/same int(p1) */
      char    *sp, *nxp;              /* string pntrs into srtblk text        */
      int     op;                     /* opcode of current event              */
      int     warpin;                 /* input format sensor                  */
      int     linpos;                 /* line position sensor                 */
      int     lincnt;                 /* count of lines/section in scorefile  */
      MYFLT   prvp2 /* = -FL(1.0) */;     /* Last event time                  */
      MYFLT   clock_base /* = FL(0.0) */;
      MYFLT   warp_factor /* = FL(1.0) */;
      char    *curmem;
      char    *memend;                /* end of cur memblk                    */
      S_MACRO   *macros;
      int     next_name /* = -1 */;
      IN_STACK  *inputs, *str;
      int     input_size, input_cnt;
      int     pop;                    /* Number of macros to pop              */
      int     ingappop /* = 1 */;     /* Are we in a popable gap?             */
      int     linepos /* = -1 */;
      MARKED_SECTIONS names[30];
#define NAMELEN 40              /* array size of repeat macro names */
#define RPTDEPTH 40             /* size of repeat_n arrays (39 loop levels) */
      char    repeat_name_n[RPTDEPTH][NAMELEN];
      int     repeat_cnt_n[RPTDEPTH];
      int32   repeat_point_n[RPTDEPTH];
      int     repeat_inc_n /* = 1 */;
      S_MACRO   *repeat_mm_n[RPTDEPTH];
      int     repeat_index;
     /* Variable for repeat sections */
      char    repeat_name[NAMELEN];
      int     repeat_cnt;
      int32   repeat_point;
      int     repeat_inc /* = 1 */;
      S_MACRO   *repeat_mm;
    } sreadStatics;
    struct onefileStatics__ {
      NAMELST *toremove;
      char    *orcname;
      char    *sconame;
      char    *midname;
      int     midiSet;
      int     csdlinecount;
    } onefileStatics;
#define LBUFSIZ   32768
    struct lineventStatics__ {
      char    *Linep, *Linebufend;
      int     stdmode;
      EVTBLK  prve;
      char    *Linebuf;
      int     linebufsiz;
    } lineventStatics;
    struct musmonStatics__ {
      int32   srngcnt[MAXCHNLS], orngcnt[MAXCHNLS];
      int16   srngflg;
      int16   sectno;
      int     lplayed;
      int     segamps, sormsg;
      EVENT   **ep, **epend;      /* pointers for stepping through lplay list */
      EVENT   *lsect;
    } musmonStatics;
    struct libsndStatics__ {
      SNDFILE       *outfile;
      SNDFILE       *infile;
      char          *sfoutname;           /* soundout filename            */
      MYFLT         *inbuf;
      MYFLT         *outbuf;              /* contin sndio buffers         */
      MYFLT         *outbufp;             /* MYFLT pntr                   */
      uint32        inbufrem;
      uint32        outbufrem;            /* in monosamps                 */
                                          /* (see openin, iotranset)      */
      unsigned int  inbufsiz,  outbufsiz; /* alloc in sfopenin/out        */
      int           isfopen;              /* (real set in sfopenin)       */
      int           osfopen;              /* (real set in sfopenout)      */
      int           pipdevin, pipdevout;  /* 0: file, 1: pipe, 2: rtaudio */
      uint32        nframes               /* = 1UL */;
      FILE          *pin, *pout;
      int           dither;
    } libsndStatics;

    int           warped;               /* rdscor.c */
    int           sstrlen;
    char          *sstrbuf;
    int           enableMsgAttr;        /* csound.c */
    int           sampsNeeded;
    MYFLT         csoundScoreOffsetSeconds_;
    int           inChar_;
    int           isGraphable_;
    int           delayr_stack_depth;   /* ugens6.c */
    void          *first_delayr;
    void          *last_delayr;
    int32         revlpsiz[6];
    int32         revlpsum;
    double        rndfrac;              /* aops.c */
    MYFLT         *logbase2;
    NAMES         *omacros, *smacros;
    void          *namedgen;            /* fgens.c */
    void          *open_files;          /* fileopen.c */
    void          *searchPathCache;
    CS_HASH_TABLE *sndmemfiles;
    void          *reset_list;
    void          *pvFileTable;         /* pvfileio.c */
    int           pvNumFiles;
    int           pvErrorCode;
    /* database for deferred loading of opcode plugin libraries */
    //    void          *pluginOpcodeFiles;
    int           enableHostImplementedAudioIO;
    int           enableHostImplementedMIDIIO;
    int           hostRequestedBufferSize;
    /* engineStatus is sum of:
     *   1 (CS_STATE_PRE):  csoundPreCompile was called
     *   2 (CS_STATE_COMP): csoundCompile was called
     *   4 (CS_STATE_UTIL): csoundRunUtility was called
     *   8 (CS_STATE_CLN):  csoundCleanup needs to be called
     *  16 (CS_STATE_JMP):  csoundLongJmp was called
     */
    char          engineStatus;
    /* stdXX_assign_flags  can be {1,2,4,8} */
    char          stdin_assign_flg;
    char          stdout_assign_flg;
    char          orcname_mode;         /* 0: normal, 1: ignore, 2: fail */
    int           use_only_orchfile;
    void          *csmodule_db;
    char          *dl_opcodes_oplibs;
    char          *SF_csd_licence;
    char          *SF_id_title;
    char          *SF_id_copyright;
    int           SF_id_scopyright;
    char          *SF_id_software;
    char          *SF_id_artist;
    char          *SF_id_comment;
    char          *SF_id_date;
    void          *utility_db;
    int16         *isintab;             /* ugens3.c */
    void          *lprdaddr;            /* ugens5.c */
    int           currentLPCSlot;
    int           max_lpc_slot;
    CS_HASH_TABLE *chn_db;
    int           opcodedirWasOK;
    int           disable_csd_options;
    CsoundRandMTState randState_;
    int           performState;
    int           ugens4_rand_16;
    int           ugens4_rand_15;
    void          *schedule_kicked;
    MYFLT         *disprep_fftcoefs;
    void          *winEPS_globals;
    OPARMS        oparms_;
    REMOT_BUF     SVrecvbuf;  /* RM: rt_evt input Communications buffer */
    void          *remoteGlobals;
    /* VL: pvs bus */
    int            nchanif, nchanof;
    char           *chanif, *chanof;
    /* VL: internal yield callback */
    void          *multiThreadedBarrier1;
    void          *multiThreadedBarrier2;
    int           multiThreadedComplete;
    THREADINFO    *multiThreadedThreadInfo;
    struct dag_t        *multiThreadedDag;
    pthread_barrier_t   *barrier1;
    pthread_barrier_t   *barrier2;
    /* Statics from cs_par_dispatch; */
    struct global_var_lock_t *global_var_lock_root;
    struct global_var_lock_t **global_var_lock_cache;
    int           global_var_lock_count;
    /* statics from cs_par_orc_semantic_analysis */
    struct instr_semantics_t *instCurr;
    struct instr_semantics_t *instRoot;
    int           inInstr;
    int           dag_changed;
    int           dag_num_active;
    INSDS         **dag_task_map;
    volatile enum state    *dag_task_status;
    watchList     * volatile *dag_task_watch;
    watchList     *dag_wlmm;
    char          **dag_task_dep;
    int           dag_task_max_size;
    uint32_t      tempStatus;    /* keeps track of which files are temps */
    int           orcLineOffset; /* 1 less than 1st orch line in the CSD */
    int           scoLineOffset; /* 1 less than 1st score line in the CSD */
    char*         csdname;
  /* original CSD name; do not free() */
    int           parserUdoflag;
    int           parserNamedInstrFlag;
    int           tran_nchnlsi;
    int           scnt;         /* Count of strings */
    int           strsiz;       /* length of current strings space */
    FUNC          *sinetable;   /* A useful table */
    int           sinelength;   /* Size of table */
    MYFLT         *powerof2;    /* pow2 table */
    MYFLT         *cpsocfrc;    /* cps conv table */
    CORFIL*       expanded_orc; /* output of preprocessor */
    CORFIL*       expanded_sco; /* output of preprocessor */
    char          *filedir[256];/* for location directory */
    void          *message_buffer;
    int           jumpset;
    int           info_message_request;
    int           modules_loaded;
    MYFLT         _system_sr;
    void*         csdebug_data; /* debugger data */
    int (*kperf)(CSOUND *); /* kperf function pointer, to switch between debug
                               and nodebug function */
    int           score_parser;
    CS_HASH_TABLE* symbtab;
    /*struct CSOUND_ **self;*/
    /**@}*/
#endif  /* __BUILDING_LIBCSOUND */
  };

/*
 * Move the C++ guards to enclose the entire file,
 * in order to enable C++ to #include this file.
 */

#define LINKAGE_BUILTIN(name)                                         \
long name##_init(CSOUND *csound, OENTRY **ep)                         \
{   (void) csound; *ep = name; return (long) (sizeof(name));  }

#define FLINKAGE_BUILTIN(name)                                        \
NGFENS* name##_init(CSOUND *csound)                                   \
{   (void) csound; return name; }

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif  /* CSOUNDCORE_H */
