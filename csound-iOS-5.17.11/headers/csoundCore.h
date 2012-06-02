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
#ifdef PARCS
#include <pthread.h>
#include "cs_par_structs.h"
#endif /* PARCS */
#include <stdarg.h>
#include <setjmp.h>

/*
#include <sndfile.h>
JPff:  But this gives warnings in many files as rewriteheader expects
to have an argument of SNDFILE*.  Might be able to fix with a void*
VL: moved to allow opcodes to be built without libsndfile headers
The libsndfile header is now place only where it is used:
Engine/envvar.c
Engine/memfiles.c
Engine/libsnd_u.c
OOps/sndinfUG.c
Opcodes/fout.c
util/atsa.c
Opcodes/stdopcode.h
H/diskin2.h
H/soundio.h
util/pvanal.c
util/sndinfo.c
util/xtrct.c
*/

#include "csound.h"


#ifdef __cplusplus
extern "C" {
#endif /*  __cplusplus */

#ifdef __MACH__
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
#define INOCOUNT    ORTXT.inoffs->count
#define OUTOCOUNT   ORTXT.outoffs->count
#define XINCODE     ORTXT.xincod
#  define XINARG1   (p->XINCODE & 1)
#  define XINARG2   (p->XINCODE & 2)
#  define XINARG3   (p->XINCODE & 4)
#  define XINARG4   (p->XINCODE & 8)
#  define XINARG5   (p->XINCODE &16)
#define XOUTCODE    ORTXT.xoutcod
#define XSTRCODE    ORTXT.xincod_str
#define XOUTSTRCODE ORTXT.xoutcod_str

#define CURTIME (((double)csound->icurTime)/((double)csound->esr))
#define CURTIME_inc (((double)csound->ksmps)/((double)csound->esr))

#define MAXLEN     0x1000000L
#define FMAXLEN    ((MYFLT)(MAXLEN))
#define PHMASK     0x0FFFFFFL
#define PFRAC(x)   ((MYFLT)((x) & ftp->lomask) * ftp->lodiv)
#define MAXPOS     0x7FFFFFFFL

#define BYTREVS(n) ((n>>8  & 0xFF) | (n<<8 & 0xFF00))
#define BYTREVL(n) ((n>>24 & 0xFF) | (n>>8 & 0xFF00L) | \
                    (n<<8 & 0xFF0000L) | (n<<24 & 0xFF000000L))

#define OCTRES     8192
#define CPSOCTL(n) ((MYFLT)(1 << ((int)(n) >> 13)) * csound->cpsocfrc[(int)(n) & 8191])

#define LOBITS     10
#define LOFACT     1024
  /* LOSCAL is 1/LOFACT as MYFLT */
#define LOSCAL     FL(0.0009765625)

#define LOMASK     1023

#define SSTRCOD    3945467
#define SSTRCOD1   3945466
#define SSTRCOD2   3945465
#define SSTRCOD3   3945464
#define SSTRSIZ    200
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
/* VL: this is a silly redefinition that can only
   cause confusion
#define printf  use_csoundMessage_instead_of_printf
*/
  typedef struct CORFIL {
    char    *body;
    int     len;
    int     p;
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
    int     expr_opt;       /* IV - Jan 27 2005: for --expression-opt */
    float   sr_override, kr_override;
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
#ifdef ENABLE_NEW_PARSER
    int     newParser; /* SYY - July 30, 2006: for --new-parser */
    int     calculateWeights;
#endif /* ENABLE_NEW_PARSE */
  } OPARMS;

  typedef struct arglst {
    int     count;
    char    *arg[1];
  } ARGLST;

  typedef struct argoffs {
    int     count;
    int     indx[1];
  } ARGOFFS;

  /**
   * Storage for parsed orchestra code, for each opcode in an INSTRTXT.
   */
  typedef struct text {
    int     linenum;        /* Line num in orch file (currently buggy!)  */
    int     opnum;          /* Opcode index in opcodlst[] */
    char    *opcod;         /* Pointer to opcode name in global pool */
    ARGLST  *inlist;        /* Input args (pointer to item in name list) */
    ARGLST  *outlist;
    ARGOFFS *inoffs;        /* Input args (index into list of values) */
    ARGOFFS *outoffs;
    int     xincod;         /* Rate switch for multi-rate opcode functions */
    int     xoutcod;        /* output rate switch (IV - Sep 1 2002) */
    int     xincod_str;     /* Type switch for string arguments */
    int     xoutcod_str;
    char    intype;         /* Type of first input argument (g,k,a,w etc) */
    char    pftype;         /* Type of output argument (k,a etc) */
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
    int     lclkcnt, dummy01;       /* Storage reqs for this instr */
    int     lclwcnt, lclacnt;
    int     lclpcnt, lclscnt;
    int     lclfixed, optxtcount;
    int16   muted;
    int32   localen;
    int32   opdstot;                /* Total size of opds structs in instr */
    int32   *inslist;               /* Only used in parsing (?) */
    MYFLT   *psetdata;              /* Used for pset opcode */
    struct insds * instance;        /* Chain of allocated instances of
                                       this instrument */
    struct insds * lst_instance;    /* last allocated instance */
    struct insds * act_instance;    /* Chain of free (inactive) instances */
                                    /* (pointer to next one is INSDS.nxtact) */
    struct instr * nxtinstxt;       /* Next instrument in orch (num order) */
    int     active;                 /* To count activations for control */
    int     maxalloc;
    MYFLT   cpuload;                /* % load this instrumemnt makes */
    struct opcodinfo *opcode_info;  /* IV - Nov 10 2002 */
    char    *insname;               /* instrument name */
    int     instcnt;                /* Count number of instances ever */
  } INSTRTXT;

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
    /* user defined opcode I/O buffers */
    void    *opcod_iobufs;
    void    *opcod_deact, *subins_deact;
    /* opcodes to be run at note deactivation */
    void    *nxtd;
    /* Copy of required p-field values for quick access */
    MYFLT   p0;
    MYFLT   p1;
    MYFLT   p2;
    MYFLT   p3;
  } INSDS;

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

  typedef struct oentry {
    char    *opname;
    uint16  dsblksiz;
    uint16  thread;
    char    *outypes;
    char    *intypes;
    int     (*iopadr)(CSOUND *, void *p);
    int     (*kopadr)(CSOUND *, void *p);
    int     (*aopadr)(CSOUND *, void *p);
    void    *useropinfo;    /* user opcode parameters */
    int     prvnum;         /* IV - Oct 31 2002 */
  } OENTRY;

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

  /**
   * This struct holds the data for one score event.
   */
  typedef struct event {
    /** String argument (NULL if none) */
    char    *strarg;
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
    char    estrarg[3];         /* Extra strings */
  } EVTBLK;

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
    int32    flen;
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
    /** GEN01 parameters */
    GEN01ARGS gen01args;
    /** table data (flen + 1 MYFLT values) */
    MYFLT   ftable[1];
  } FUNC;

  typedef struct {
    CSOUND  *csound;
    int32    flen;
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
#define SETEND  7

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

  typedef struct opcodinfo {
    int32    instno;
    char    *name, *intypes, *outtypes;
    int16   inchns, outchns, perf_incnt, perf_outcnt;
    int16   *in_ndx_list, *out_ndx_list;
    INSTRTXT *ip;
    struct opcodinfo *prv;
  } OPCODINFO;

  typedef struct polish {
    char    opcod[12];
    int     incount;
    char    *arg[4];     /* Was [4][12] */
  } POLISH;

  typedef struct token {
    char    *str;
    int16   prec;
  } TOKEN;

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

#endif  /* __BUILDING_LIBCSOUND */
  /**
   * Contains all function pointers, data, and data pointers required
   * to run one instance of Csound.
   */


  struct CSOUND_ {
    /* Csound API function pointers (320 total) */
    int (*GetVersion)(void);
    int (*GetAPIVersion)(void);
    void *(*GetHostData)(CSOUND *);
    void (*SetHostData)(CSOUND *, void *hostData);
    CSOUND *(*Create)(void *hostData);
    int (*Compile)(CSOUND *, int argc, char **argv);
    int (*Perform)(CSOUND *);
    int (*PerformKsmps)(CSOUND *);
    int (*PerformBuffer)(CSOUND *);
    int (*Cleanup)(CSOUND *);
    void (*Reset)(CSOUND *);
    void (*Destroy)(CSOUND *);
    MYFLT (*GetSr)(CSOUND *);
    MYFLT (*GetKr)(CSOUND *);
    int (*GetKsmps)(CSOUND *);
    int (*GetNchnls)(CSOUND *);
    int (*GetSampleFormat)(CSOUND *);
    int (*GetSampleSize)(CSOUND *);
    long (*GetInputBufferSize)(CSOUND *);
    long (*GetOutputBufferSize)(CSOUND *);
    MYFLT *(*GetInputBuffer)(CSOUND *);
    MYFLT *(*GetOutputBuffer)(CSOUND *);
    MYFLT *(*GetSpin)(CSOUND *);
    MYFLT *(*GetSpout)(CSOUND *);
    double (*GetScoreTime)(CSOUND *);
    void (*SetMakeXYinCallback)(CSOUND *,
                                void (*)(CSOUND *, XYINDAT *, MYFLT, MYFLT));
    void (*SetReadXYinCallback)(CSOUND *, void (*)(CSOUND *, XYINDAT *));
    void (*SetKillXYinCallback)(CSOUND *, void (*)(CSOUND *, XYINDAT *));
    int (*IsScorePending)(CSOUND *);
    void (*SetScorePending)(CSOUND *, int pending);
    MYFLT (*GetScoreOffsetSeconds)(CSOUND *);
    void (*SetScoreOffsetSeconds)(CSOUND *, MYFLT offset);
    void (*RewindScore)(CSOUND *);
    CS_PRINTF2 void (*Message)(CSOUND *, const char *fmt, ...);
    CS_PRINTF3 void (*MessageS)(CSOUND *, int attr, const char *fmt, ...);
    void (*MessageV)(CSOUND *, int attr, const char *format, va_list args);
    void (*DeleteUtilityList)(CSOUND *, char **lst);
    void (*DeleteChannelList)(CSOUND *, CsoundChannelListEntry *lst);
    void (*SetMessageCallback)(CSOUND *,
                void (*csoundMessageCallback)(CSOUND *,
                                              int attr, const char *format,
                                              va_list valist));
    void (*DeleteCfgVarList)(csCfgVariable_t **lst);
    int (*GetMessageLevel)(CSOUND *);
    void (*SetMessageLevel)(CSOUND *, int messageLevel);
    void (*InputMessage)(CSOUND *, const char *message__);
    void (*KeyPressed)(CSOUND *, char c__);
    void (*SetInputValueCallback)(CSOUND *,
                void (*inputValueCalback)(CSOUND *, const char *channelName,
                                                    MYFLT *value));
    void (*SetOutputValueCallback)(CSOUND *,
                void (*outputValueCalback)(CSOUND *, const char *channelName,
                                                     MYFLT value));
    int (*ScoreEvent)(CSOUND *,
                      char type, const MYFLT *pFields, long numFields);
    int (*ScoreEventAbsolute)(CSOUND *,
                      char type, const MYFLT *pFields, long numFields, double time_ofs);
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
    int (*SetIsGraphable)(CSOUND *, int isGraphable);
    void (*SetMakeGraphCallback)(CSOUND *,
                void (*makeGraphCallback)(CSOUND *, WINDAT *p,
                                                    const char *name));
    void (*SetDrawGraphCallback)(CSOUND *,
                void (*drawGraphCallback)(CSOUND *, WINDAT *p));
    void (*SetKillGraphCallback)(CSOUND *,
                void (*killGraphCallback)(CSOUND *, WINDAT *p));
    void (*SetExitGraphCallback)(CSOUND *, int (*exitGraphCallback)(CSOUND *));
    int (*NewOpcodeList)(CSOUND *, opcodeListEntry **);
    void (*DisposeOpcodeList)(CSOUND *, opcodeListEntry *);
    int (*AppendOpcode)(CSOUND *, const char *opname, int dsblksiz,
                        int thread, const char *outypes, const char *intypes,
                        int (*iopadr)(CSOUND *, void *),
                        int (*kopadr)(CSOUND *, void *),
                        int (*aopadr)(CSOUND *, void *));
    int (*AppendOpcodes)(CSOUND *, const OENTRY *opcodeList, int n);
    int (*OpenLibrary)(void **library, const char *libraryPath);
    int (*CloseLibrary)(void *library);
    void *(*GetLibrarySymbol)(void *library, const char *procedureName);
    int (*CheckEvents)(CSOUND *);
    void (*SetYieldCallback)(CSOUND *, int (*yieldCallback)(CSOUND *));
    const char *(*GetEnv)(CSOUND *, const char *name);
    char *(*FindInputFile)(CSOUND *, const char *filename, const char *envList);
    char *(*FindOutputFile)(CSOUND *,
                            const char *filename, const char *envList);
    void (*SetPlayopenCallback)(CSOUND *,
                int (*playopen__)(CSOUND *, const csRtAudioParams *parm));
    void (*SetRtplayCallback)(CSOUND *,
                void (*rtplay__)(CSOUND *, const MYFLT *outBuf, int nbytes));
    void (*SetRecopenCallback)(CSOUND *,
                int (*recopen__)(CSOUND *, const csRtAudioParams *parm));
    void (*SetRtrecordCallback)(CSOUND *,
                int (*rtrecord__)(CSOUND *, MYFLT *inBuf, int nbytes));
    void (*SetRtcloseCallback)(CSOUND *, void (*rtclose__)(CSOUND *));
    void (*AuxAlloc)(CSOUND *, size_t nbytes, AUXCH *auxchp);
    void *(*Malloc)(CSOUND *, size_t nbytes);
    void *(*Calloc)(CSOUND *, size_t nbytes);
    void *(*ReAlloc)(CSOUND *, void *oldp, size_t nbytes);
    void (*Free)(CSOUND *, void *ptr);
    /* Internal functions that are needed */
    void (*dispset)(CSOUND *, WINDAT *, MYFLT *, int32, char *, int, char *);
    void (*display)(CSOUND *, WINDAT *);
    int (*dispexit)(CSOUND *);
    MYFLT (*intpow)(MYFLT, int32);
    MEMFIL *(*ldmemfile)(CSOUND *, const char *);  /* use ldmemfile2 instead */
    int32 (*strarg2insno)(CSOUND *, void *p, int is_string);
    char *(*strarg2name)(CSOUND *, char *, void *, const char *, int);
    int (*hfgens)(CSOUND *, FUNC **, const EVTBLK *, int);
    int (*insert_score_event)(CSOUND *, EVTBLK *, double);
    int (*FTAlloc)(CSOUND *, int tableNum, int len);
    int (*FTDelete)(CSOUND *, int tableNum);
    FUNC *(*FTFind)(CSOUND *, MYFLT *argp);
    FUNC *(*FTFindP)(CSOUND *, MYFLT *argp);
    FUNC *(*FTnp2Find)(CSOUND *, MYFLT *argp);
    int (*GetTable)(CSOUND *, MYFLT **tablePtr, int tableNum);
    SNDMEMFILE *(*LoadSoundFile)(CSOUND *, const char *, void *);
    char *(*getstrformat)(int format);
    int (*sfsampsize)(int format);
    char *(*type2string)(int type);
    void *(*SAsndgetset)(CSOUND *,
                         char *, void *, MYFLT *, MYFLT *, MYFLT *, int);
    void *(*sndgetset)(CSOUND *, void *);
    int (*getsndin)(CSOUND *, void *, MYFLT *, int, void *);
    void (*rewriteheader)(void *ofd);
    int (*Rand31)(int *seedVal);
    void (*FDRecord)(CSOUND *, FDCH *fdchp);
    void (*FDClose)(CSOUND *, FDCH *fdchp);
    void (*SetDebug)(CSOUND *, int d);
    int (*GetDebug)(CSOUND *);
    int (*TableLength)(CSOUND *, int table);
    MYFLT (*TableGet)(CSOUND *, int table, int index);
    void (*TableSet)(CSOUND *, int table, int index, MYFLT value);
    void *(*CreateThread)(uintptr_t (*threadRoutine)(void *), void *userdata);
    uintptr_t (*JoinThread)(void *thread);
    void *(*CreateThreadLock)(void);
    void (*DestroyThreadLock)(void *lock);
    int (*WaitThreadLock)(void *lock, size_t milliseconds);
    void (*NotifyThreadLock)(void *lock);
    void (*WaitThreadLockNoTimeout)(void *lock);
    void (*Sleep)(size_t milliseconds);
    void (*InitTimerStruct)(RTCLOCK *);
    double (*GetRealTime)(RTCLOCK *);
    double (*GetCPUTime)(RTCLOCK *);
    uint32_t (*GetRandomSeedFromTime)(void);
    void (*SeedRandMT)(CsoundRandMTState *p,
                       const uint32_t *initKey, uint32_t keyLength);
    uint32_t (*RandMT)(CsoundRandMTState *p);
    int (*PerformKsmpsAbsolute)(CSOUND *);
    char *(*LocalizeString)(const char *);
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
    int (*GetSizeOfMYFLT)(void);
    void **(*GetRtRecordUserData)(CSOUND *);
    void **(*GetRtPlayUserData)(CSOUND *);
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
    int (*AddUtility)(CSOUND *, const char *name,
                      int (*UtilFunc)(CSOUND *, int, char **));
    int (*RunUtility)(CSOUND *, const char *name, int argc, char **argv);
    char **(*ListUtilities)(CSOUND *);
    int (*SetUtilityDescription)(CSOUND *, const char *utilName,
                                           const char *utilDesc);
    const char *(*GetUtilityDescription)(CSOUND *, const char *utilName);
    int (*RegisterSenseEventCallback)(CSOUND *, void (*func)(CSOUND *, void *),
                                                void *userData);
    int (*RegisterDeinitCallback)(CSOUND *, void *p,
                                            int (*func)(CSOUND *, void *));
    int (*RegisterResetCallback)(CSOUND *, void *userData,
                                           int (*func)(CSOUND *, void *));
    void *(*CreateFileHandle)(CSOUND *, void *, int, const char *);
    /* Do not use FileOpen in new code; it has been replaced by FileOpen2 */
    void *(*FileOpen)(CSOUND *,
                      void *, int, const char *, void *, const char *);
    char *(*GetFileName)(void *);
    int (*FileClose)(CSOUND *, void *);
    /* PVOC-EX system */
    int (*PVOC_CreateFile)(CSOUND *, const char *,
                           uint32, uint32, uint32,
                           uint32, int32, int, int,
                           float, float *, uint32);
    int (*PVOC_OpenFile)(CSOUND *, const char *, void *, void *);
    int (*PVOC_CloseFile)(CSOUND *, int);
    int (*PVOC_PutFrames)(CSOUND *, int, const float *, int32);
    int (*PVOC_GetFrames)(CSOUND *, int, float *, uint32);
    int (*PVOC_FrameCount)(CSOUND *, int);
    int (*PVOC_fseek)(CSOUND *, int, int);
    const char *(*PVOC_ErrorString)(CSOUND *);
    int (*PVOCEX_LoadFile)(CSOUND *, const char *, PVOCEX_MEMFILE *);
    char *(*GetOpcodeName)(void *p);
    int (*GetInputArgCnt)(void *p);
    unsigned long (*GetInputArgAMask)(void *p);
    unsigned long (*GetInputArgSMask)(void *p);
    char *(*GetInputArgName)(void *p, int n);
    int (*GetOutputArgCnt)(void *p);
    unsigned long (*GetOutputArgAMask)(void *p);
    unsigned long (*GetOutputArgSMask)(void *p);
    char *(*GetOutputArgName)(void *p, int n);
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
    CS_NORETURN CS_PRINTF2 void (*Die)(CSOUND *, const char *msg, ...);
    CS_PRINTF2 int (*InitError)(CSOUND *, const char *msg, ...);
    CS_PRINTF2 int (*PerfError)(CSOUND *, const char *msg, ...);
    CS_PRINTF2 void (*Warning)(CSOUND *, const char *msg, ...);
    CS_PRINTF2 void (*DebugMsg)(CSOUND *, const char *msg, ...);
    CS_NORETURN void (*LongJmp)(CSOUND *, int);
    CS_PRINTF2 void (*ErrorMsg)(CSOUND *, const char *fmt, ...);
    void (*ErrMsgV)(CSOUND *, const char *hdr, const char *fmt, va_list);
    int (*GetChannelPtr)(CSOUND *, MYFLT **p, const char *name, int type);
    int (*ListChannels)(CSOUND *, CsoundChannelListEntry **lst);
    int (*SetControlChannelParams)(CSOUND *, const char *name,
                                   int type, MYFLT dflt, MYFLT min, MYFLT max);
    int (*GetControlChannelParams)(CSOUND *, const char *name,
                                   MYFLT *dflt, MYFLT *min, MYFLT *max);
    int (*ChanIKSet)(CSOUND *, MYFLT value, int n);
    int (*ChanOKGet)(CSOUND *, MYFLT *value, int n);
    int (*ChanIASet)(CSOUND *, const MYFLT *value, int n);
    int (*ChanOAGet)(CSOUND *, MYFLT *value, int n);
    void (*dispinit)(CSOUND *);
    void *(*Create_Mutex)(int isRecursive);
    int (*LockMutexNoWait)(void *mutex_);
    void (*LockMutex)(void *mutex_);
    void (*UnlockMutex)(void *mutex_);
    void (*DestroyMutex)(void *mutex_);
    long (*RunCommand)(const char * const *argv, int noWait);
    void *(*GetCurrentThreadID)(void);
    void (*SetChannelIOCallback)(CSOUND *, CsoundChannelIOCallback_t func);
    int (*Set_Callback)(CSOUND *, int (*func)(void *, void *, unsigned int),
                                  void *userData, unsigned int typeMask);
    void (*Remove_Callback)(CSOUND *,
                            int (*func)(void *, void *, unsigned int));
    int (*PvsinSet)(CSOUND *, const PVSDATEXT *value, int n);
    int (*PvsoutGet)(CSOUND *, PVSDATEXT *value, int n);
    void (*SetInternalYieldCallback)(CSOUND *,
                       int (*yieldCallback)(CSOUND *));
    void *(*CreateBarrier)(unsigned int max);
    int (*DestroyBarrier)(void *);
    int (*WaitBarrier)(void *);
    void *(*FileOpen2)(CSOUND *, void *, int, const char *, void *,
                      const char *, int, int);
    int (*type2csfiletype)(int type, int encoding);
    MEMFIL *(*ldmemfile2)(CSOUND *, const char *, int);
    void (*NotifyFileOpened)(CSOUND*, const char*, int, int, int);
    int (*sftype2csfiletype)(int type);
    int (*insert_score_event_at_sample)(CSOUND *, EVTBLK *, long);
    int *(*GetChannelLock)(CSOUND *, const char *name, int type);
    MEMFIL *(*ldmemfile2withCB)(CSOUND *, const char *, int,
                                int (*callback)(CSOUND *, MEMFIL *));
    void (*AddSpinSample)(CSOUND *, int, int, MYFLT);
    MYFLT (*GetSpoutSample)(CSOUND *, int, int);
    int (*ChanIKSetValue)(CSOUND *, int channel, MYFLT value);
    MYFLT (*ChanOKGetValue)(CSOUND *, int channel);
    int (*ChanIASetSample)(CSOUND *, int channel, int frame, MYFLT sample);
    MYFLT (*ChanOAGetSample)(CSOUND *, int channel, int frame);
    void (*Stop)(CSOUND *);
    void *(*GetNamedGens)(CSOUND *);
 /* SUBR dummyfn_1; */
    MYFLT (*Pow2)(CSOUND *, MYFLT a);
    SUBR dummyfn_2[75];
    int           dither_output;
    void          *flgraphGlobals;
    char          *delayederrormessages;
    void          *printerrormessagesflag;
    /* ----------------------- public data fields ----------------------- */
    /** used by init and perf loops */
    OPDS          *ids, *pds;
    int           ksmps, global_ksmps, nchnls, spoutactive;
    long          kcounter, global_kcounter;
    int           reinitflag;
    int           tieflag;
    MYFLT         esr, onedsr, sicvt;
    MYFLT         tpidsr, pidsr, mpidsr, mtpdsr;
    MYFLT         onedksmps;
    MYFLT         ekr, global_ekr;
    MYFLT         onedkr;
    MYFLT         kicvt;
    MYFLT         e0dbfs, dbfs_to_float;
    /** start time of current section    */
    double        timeOffs, beatOffs;
    /** current time in seconds, inc. per kprd */
    int64_t       icurTime;   /* Current time in samples */
    double        curTime_inc;
    /** current time in beats, inc per kprd */
    double        curBeat, curBeat_inc;
    /** beat time = 60 / tempo           */
    int64_t       ibeatTime;   /* Beat time in samples */
#if defined(HAVE_PTHREAD_SPIN_LOCK) && defined(PARCS)
    pthread_spinlock_t spoutlock, spinlock;
#else
    int           spoutlock, spinlock;
#endif /* defined(HAVE_PTHREAD_SPIN_LOCK) && defined(PARCS) */
    /* Widgets */
    void          *widgetGlobals;
    /** reserved for std opcode library  */
    void          *stdOp_Env;
    MYFLT         *zkstart;
    MYFLT         *zastart;
    long          zklast;
    long          zalast;
    MYFLT         *spin;
    MYFLT         *spout;
    int           nspin;
    int           nspout;
    OPARMS        *oparms;
    EVTBLK        *currevent;
    INSDS         *curip;
    void          *hostdata;
    void          *rtRecord_userdata;
    void          *rtPlay_userdata;
    char          *orchname, *scorename;
    CORFIL        *orchstr, *scorestr;
    int           holdrand;
    /** max. length of string variables + 1  */
    int           strVarMaxLen;
    int           maxinsno;
    int           strsmax;
    char          **strsets;
    INSTRTXT      **instrtxtp;
    /** reserve space for up to 4 MIDI devices */
    MCHNBLK       *m_chnbp[64];
    RTCLOCK       *csRtClock;
    CsoundRandMTState *csRandState;
    int           randSeed1;
    int           randSeed2;
#if defined(HAVE_PTHREAD_SPIN_LOCK) && defined(PARCS)
    pthread_spinlock_t memlock;
#else
    int           memlock;
#endif /* defined(HAVE_PTHREAD_SPIN_LOCK) && defined(PARCS */
    int           floatsize;
    int           inchnls;      /* Not fully used yet -- JPff */
    int   dummyint[7];
    long  dummyint32[10];
    /* ------- private data (not to be used by hosts or externals) ------- */
#ifdef __BUILDING_LIBCSOUND
    /* callback function pointers */
    SUBR          first_callback_;
    void          (*InputValueCallback_)(CSOUND *,
                                         const char *channelName, MYFLT *value);
    void          (*OutputValueCallback_)(CSOUND *,
                                          const char *channelName, MYFLT value);
    void          (*csoundMessageCallback_)(CSOUND *, int attr,
                                            const char *format, va_list args);
    int           (*csoundConfigureCallback_)(CSOUND *);
    void          (*csoundMakeGraphCallback_)(CSOUND *, WINDAT *windat,
                                                        const char *name);
    void          (*csoundDrawGraphCallback_)(CSOUND *, WINDAT *windat);
    void          (*csoundKillGraphCallback_)(CSOUND *, WINDAT *windat);
    int           (*csoundExitGraphCallback_)(CSOUND *);
    int           (*csoundYieldCallback_)(CSOUND *);
    void          (*csoundMakeXYinCallback_)(CSOUND *, XYINDAT *, MYFLT, MYFLT);
    void          (*csoundReadXYinCallback_)(CSOUND *, XYINDAT *);
    void          (*csoundKillXYinCallback_)(CSOUND *, XYINDAT *);
    void          (*cscoreCallback_)(CSOUND *);
    void          (*FileOpenCallback_)(CSOUND*, const char*, int, int, int);
    SUBR          last_callback_;
    /* these are not saved on RESET */
    int           (*playopen_callback)(CSOUND *, const csRtAudioParams *parm);
    void          (*rtplay_callback)(CSOUND *, const MYFLT *outBuf, int nbytes);
    int           (*recopen_callback)(CSOUND *, const csRtAudioParams *parm);
    int           (*rtrecord_callback)(CSOUND *, MYFLT *inBuf, int nbytes);
    void          (*rtclose_callback)(CSOUND *);
    /* end of callbacks */
    int           nchanik, nchania, nchanok, nchanoa;
    MYFLT         *chanik, *chania, *chanok, *chanoa;
    MYFLT         cpu_power_busy;
    char          *xfilename;
    /* oload.h */
    int16         nlabels;
    int16         ngotos;
    int           peakchunks;
    int           keep_tmp;
    OENTRY        *opcodlst;
    int           *opcode_list;
    OENTRY        *oplstend;
    int           maxopcno;
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
    MYFLT         *pool;
    int           *argoffspace;
    INSDS         *frstoff;
    jmp_buf       exitjmp;
    SRTBLK        *frstbp;
    int           sectcnt;
    int           inerrcnt, synterrcnt, perferrcnt;
    INSTRTXT      instxtanchor;
    INSDS         actanchor;
    int32          rngcnt[MAXCHNLS];
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
    MYFLT         tran_sr, tran_kr, tran_ksmps;
    MYFLT         tran_0dbfs;
    int           tran_nchnls;
    OPCODINFO     *opcodeInfo;
    void          *instrumentNames;
    void          *strsav_str;
    void          *strsav_space;
    FUNC**        flist;
    int           maxfnum;
    GEN           *gensub;
    int           genmax;
    int           ftldno;
    void          **namedGlobals;
    int           namedGlobalsCurrLimit;
    int           namedGlobalsMaxLimit;
    void          **cfgVariableDB;
    double        prvbt, curbt, nxtbt;
    double        curp2, nxtim;
    int64_t       cyclesRemaining;
    EVTBLK        evt;
    void          *memalloc_db;
    MGLOBAL       *midiGlobals;
    void          *envVarDB;
    MEMFIL        *memfiles;
    PVOCEX_MEMFILE *pvx_memfiles;
    int           FFT_max_size;
    void          *FFT_table_1;
    void          *FFT_table_2;
    /* statics from twarp.c should be TSEG* */
    void          *tseg, *tpsave, *tplim;
    /* Statics from express.c */
    int32          polmax;
    int32          toklen;
    char          *tokenstring;
    POLISH        *polish;
    TOKEN         *token;
    TOKEN         *tokend;
    TOKEN         *tokens;
    TOKEN         **tokenlist;
    int           toklength;
    int           acount, kcount, icount, Bcount, bcount;
    char          *stringend;
    TOKEN         **revp, **pushp, **argp, **endlist;
    char          *assign_outarg;
    int           argcnt_offs, opcode_is_assign, assign_type;
    int           strVarSamples;    /* number of MYFLT locations for string */
    MYFLT         *gbloffbas;       /* was static in oload.c */
    void          *otranGlobals;
    void          *rdorchGlobals;
    void          *sreadGlobals;
    void          *extractGlobals;
    void          *oneFileGlobals;
    void          *lineventGlobals;
    void          *musmonGlobals;
    void          *libsndGlobals;
    void          (*spinrecv)(CSOUND *);
    void          (*spoutran)(CSOUND *);
    int           (*audrecv)(CSOUND *, MYFLT *, int);
    void          (*audtran)(CSOUND *, const MYFLT *, int);
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
    void          *sndmemfiles;
    void          *reset_list;
    void          *pvFileTable;         /* pvfileio.c */
    int           pvNumFiles;
    int           pvErrorCode;
    /* database for deferred loading of opcode plugin libraries */
    void          *pluginOpcodeFiles, *pluginOpcodeDB;
    int           enableHostImplementedAudioIO;
    int           hostRequestedBufferSize;
    /* engineState is sum of:
     *   1 (CS_STATE_PRE):  csoundPreCompile was called
     *   2 (CS_STATE_COMP): csoundCompile was called
     *   4 (CS_STATE_UTIL): csoundRunUtility was called
     *   8 (CS_STATE_CLN):  csoundCleanup needs to be called
     *  16 (CS_STATE_JMP):  csoundLongJmp was called
     */
    int           engineState;
    int           stdin_assign_flg;
    int           stdout_assign_flg;
    int           orcname_mode;         /* 0: normal, 1: ignore, 2: fail */
    void          *csmodule_db;
    char          *dl_opcodes_oplibs;
    char          *SF_csd_licence;
    char          *SF_id_title;
    char          *SF_id_copyright;
    char          *SF_id_software;
    char          *SF_id_artist;
    char          *SF_id_comment;
    char          *SF_id_date;
    void          *utility_db;
    int16         *isintab;             /* ugens3.c */
    void          *lprdaddr;            /* ugens5.c */
    int           currentLPCSlot;
    int           max_lpc_slot;
    void          *chn_db;
    int           opcodedirWasOK;
    int           disable_csd_options;
    CsoundRandMTState randState_;
    int           performState;
    int           ugens4_rand_16;
    int           ugens4_rand_15;
    void          *schedule_kicked;
    LBLBLK        **lopds;
    void          *larg;        /* this is actually LARGNO* */
    MYFLT         *disprep_fftcoefs;
    void          *winEPS_globals;
    OPARMS        oparms_;
    int32          instxtcount, optxtsize;
    int32          poolcount, gblfixed, gblacount, gblscount;
    CsoundChannelIOCallback_t   channelIOCallback_;
    int           (*doCsoundCallback)(CSOUND *, void *, unsigned int);
    const unsigned char *strhash_tabl_8;
    unsigned int  (*strHash32)(const char *s);
    REMOT_BUF     SVrecvbuf;  /* RM: rt_evt input Communications buffer */
    void          *remoteGlobals;
    /* VL: pvs bus */
    int            nchanif, nchanof;
    char           *chanif, *chanof;
    /* VL: internal yield callback */
    int           (*csoundInternalYieldCallback_)(CSOUND *);
    void          *multiThreadedBarrier1;
    void          *multiThreadedBarrier2;
    int           multiThreadedComplete;
    THREADINFO    *multiThreadedThreadInfo;
    INSDS         *multiThreadedStart;
    INSDS         *multiThreadedEnd;
#ifdef PARCS
    char                *weight_info;
    char                *weight_dump;
    char                *weights;
    struct dag_t        *multiThreadedDag;
    pthread_barrier_t   *barrier1;
    pthread_barrier_t   *barrier2;
    /* Statics from cs_par_dispatch; */
    struct global_var_lock_t *global_var_lock_root;
    struct global_var_lock_t **global_var_lock_cache;
    int           global_var_lock_count;
    int           opcode_weight_cache_ctr;
    struct opcode_weight_cache_entry_t
                  *opcode_weight_cache[OPCODE_WEIGHT_CACHE_SIZE];
    int           opcode_weight_have_cache;
    struct        dag_cache_entry_t *cache[DAG_2_CACHE_SIZE];
    /* statics from cs_par_orc_semantic_analysis */
    struct instr_semantics_t *instCurr;
    struct instr_semantics_t *instRoot;
    int           inInstr;
#endif
    uint32_t      tempStatus;    /* keeps track of which files are temps */
    int           orcLineOffset; /* 1 less than 1st orch line in the CSD */
    int           scoLineOffset; /* 1 less than 1st score line in the CSD */
    char*         csdname;       /* original CSD name; do not free() */
    int           parserUdoflag;
    int           parserNamedInstrFlag;
    int           tran_nchnlsi;
    int           scnt0;        /* Count of extra strings */
    char          *sstrbuf0[3]; /* For extra strings in scores */
    int           sstrlen0[3];  /* lengths for extra strings */
    int           genlabs;      /* Count for generated labels */
    MYFLT         *powerof2;    /* pow2 table */
    MYFLT         *cpsocfrc;    /* cps conv table */
    CORFIL*       expanded_orc; /* output of preprocessor */
    char          *filedir[64]; /* for location directory */
#endif  /* __BUILDING_LIBCSOUND */
  };

/*
 * Move the C++ guards to enclose the entire file,
 * in order to enable C++ to #include this file.
 */

#define LINKAGE1(name)                                         \
long name##_init(CSOUND *csound, OENTRY **ep)           \
{   (void) csound; *ep = name; return (long) (sizeof(name));  }

#define FLINKAGE1(name)                                                 \
NGFENS* name##_init(CSOUND *csound)                         \
{   (void) csound; return name;                                     }

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif  /* CSOUNDCORE_H */
