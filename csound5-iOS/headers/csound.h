#ifndef CSOUND_H
#define CSOUND_H
/*! \mainpage
 *
 * Csound is a unit generator-based, user-programmable,
 * user-extensible computer music system.  It was originally written
 * by Barry Vercoe at the Massachusetts Institute of Technology in
 * 1984 as the first C language version of this type of
 * software. Since then Csound has received numerous contributions
 * from researchers, programmers, and musicians from around the world.
 *
 * CsoundAC is a Python extension module for doing algorithmic
 * composition, in one which one writes music by programming in
 * Python. Musical events are points in music space with dimensions
 * {time, duration, event type, instrument, pitch as MIDI key,
 * loudness as MIDI velocity, phase, pan, depth, height, pitch-class
 * set, 1}, and pieces are composed by assembling a hierarchical tree
 * of nodes in music space. Each node has its own local transformation
 * of coordinates in music space. Nodes can be empty, contain scores
 * or fragments of scores, generate scores, or transform
 * scores. CsoundAC also contains a Python interface to the Csound
 * API, making it easy to render CsoundAC compositions using Csound.
 *
 * \section section_licenses Licenses
 *
 * \subsection section_csound_license Csound, CsoundAC, and CsoundVST
 *
 * Copyright (C) 2001-2005 Michael Gogins, Matt Ingalls, John D. Ramsdell,
 *                         John P. ffitch, Istvan Varga, Victor Lazzarini
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * \subsection section_manual_license Manual
 *
 * Permission is granted to copy, distribute and/or modify this document
 * under the terms of the GNU Free Documentation License, Version 1.2 or
 * any later version published by the Free Software Foundation; with no
 * Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
 *
 * \section section_api_outline Outline of the API
 *
 * \subsection section_api_apilist The Csound Application Programming Interfaces
 *
 * The Csound Application Programming Interface (API) reference is contained herein.
 * The Csound API actually consists of several APIs:
 *
 * - The basic Csound C API. Include csound.h and link with libcsound.a.
 *   This also includes the Cscore API (see below).
 * - The basic Csound C++ API. Include csound.hpp and link with libcsound.a.
 * - The extended Csound C++ API. Include CppSound.hpp and link with
 *   libcsound.a and libcsnd.a,
 *   which adds to the Csound C++ API a CsoundFile class for loading, saving,
 *   and editing Csound orchestra and score files.
 * - The CsoundAC C++ API. Include CsoundAC.hpp and link with libcsound.a,
 *   libcsnd.a, and libCsoundAC.a.
 *   The CsoundAC class contains an instance of the CppSound class,
 *   and provides a class hierarchy for doing algorithmic composition using
 *   Michael Gogins' concept of music graphs (previously known as Silence).
 * - The Csound Python API. Import the csnd Python extension module.
 *   This provides a complete Python wrapper for csound.hpp, CppSound,
 *   and CsoundFile. The Python API provides a complete Python wrapper
 *   for the entire Csound C++ API,
 *   and the Csound C++ API reference also serves as a reference to the Python API.
 * - The CsoundAC Python API. Import the CsoundAC Python extension module.
 *   The Python API provides a complete Python wrapper
 *   for the entire CsoundAC C++ API, including Silence, and the CsoundAC
 *   C++ API reference also serves as a reference to the Python API.
 * - An experimental LISP API.
 *
 * \section section_api_c_example An Example Using the Csound API
 *
 * The Csound command--line program is itself built using the Csound API.
 * Its code reads as follows:
 *
 * \code
 * #include "csound.h"
 *
 * int main(int argc, char **argv)
 * {
 *   // Create Csound.
 *   void *csound = csoundCreate(0);
 *   // One complete compile/perform cycle.
 *   int result = csoundCompile(csound, argc, argv);
 *   if(!result) {
 *     while(csoundPerformKsmps(csound) == 0){}
 *     csoundCleanup(csound);
 *   }
 *   // Destroy Csound.
 *   csoundDestroy(csound);
 *   return result;
 * }
 * \endcode
 *
 * \section section_api_example_cpp The CsoundAC C++ API
 *
 * CsoundAC extends the Csound API with C++. There is a C++ class for
 * the Csound API proper (CppSound), another C++ class (CsoundFile)
 * for manipulating Csound files in code, and additional classes for
 * algorithmic composition based on music space. All these C++ classes
 * also have a Python interface in the CsoundAC Python extension
 * module.
 *
 * You can build CsoundAC into your own software using the CsoundAC
 * shared library and CsoundAC.hpp header file.
 *
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
 *
 * Everything that can be done using C as in the above examples can also be done
 * in a similar manner in Python or any of the other Csound API languages.
 *
 * \file
 *
 * \brief Declares the public Csound application programming interface (API).
 * \author John P. ffitch, Michael Gogins, Matt Ingalls, John D. Ramsdell,
 *         Istvan Varga and Victor Lazzarini
 *
 * \b Purposes
 *
 * The purposes of the Csound API are as follows:
 *
 * \li Declare a stable public application programming interface (API)
 *     for Csound in csound.h. This is the only header file that needs
 *     to be \#included by users of the Csound API.
 *
 * \li Hide the internal implementation details of Csound from users of
 *     the API, so that development of Csound can proceed without affecting
 *     code that uses the API.
 *
 * \b Users
 *
 * Users of the Csound API fall into two main categories: hosts, and plugins.
 *
 * \li Hosts are applications that use Csound as a software synthesis engine.
 *     Hosts can link with the Csound API either statically or dynamically.
 *
 * \li Plugins are shared libraries loaded by Csound at run time to implement
 *     external opcodes and/or drivers for audio or MIDI input and output.
 *
 * Hosts using the Csound API must \#include <csound.h>, and link with the
 * Csound API library. Plugin libraries should \#include <csdl.h> to get
 * access to the API function pointers in the CSOUND structure, and do not
 * need to link with the Csound API library.
 * Only one of csound.h and csdl.h may be included by a compilation unit.
 *
 * Hosts must first create an instance of Csound using the \c csoundCreate
 * API function. When hosts are finished using Csound, they must destroy the
 * instance of csound using the \c csoundDestroy API function.
 * Most of the other Csound API functions take the Csound instance as their
 * first argument.
 * Hosts can only call the standalone API functions declared in csound.h.
 *
 * Here is the complete code for the simplest possible Csound API host,
 * a command-line Csound application:
 *
 * \code
 *
 * #include <csound.h>
 *
 * int main(int argc, char **argv)
 * {
 *     CSOUND *csound = csoundCreate(NULL);
 *     int result = csoundCompile(csound, argc, argv);
 *     if (!result)
 *       result = csoundPerform(csound);
 *     csoundDestroy(csound);
 *     return (result >= 0 ? 0 : result);
 * }
 *
 * \endcode
 *
 * All opcodes, including plugins, receive a pointer to their host
 * instance of Csound as the first argument. Therefore, plugins MUST NOT
 * compile, perform, or destroy the host instance of Csound, and MUST call
 * the Csound API function pointers off the Csound instance pointer.
 *
 * \code
 * MYFLT sr = csound->GetSr(csound);
 * \endcode
 *
 * In general, plugins should ONLY access Csound functionality through the
 * API function pointers and public members of the CSOUND structure.
 */

/*
 * Platform-dependent definitions and declarations.
 */

#if (defined(WIN32) || defined(_WIN32)) && !defined(SWIG)
#  define PUBLIC        __declspec(dllexport)
#elif defined(__GNUC__) && !defined(__MACH__)
#  define PUBLIC        __attribute__ ( (visibility("default")) )
#else
#  define PUBLIC
#endif

#if defined(MSVC)
#  include <intrin.h> /* for _InterlockedExchange */
#endif

/**
 * Enables Python interface.
 */

#ifdef SWIG
#define CS_PRINTF2
#define CS_PRINTF3
#ifndef __MYFLT_DEF
#define __MYFLT_DEF
#ifndef USE_DOUBLE
#define MYFLT float
#else
#define MYFLT double
#endif
#endif
%module csnd
%{
#  include "sysdep.h"
#  include "text.h"
#  include <stdarg.h>
  %}
#else
#  include "sysdep.h"
#  include "text.h"
#  include <stdarg.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

  /**
   * ERROR DEFINITIONS
   */

  typedef enum
    {
      /* Completed successfully. */
      CSOUND_SUCCESS = 0,
      /* Unspecified failure. */
      CSOUND_ERROR = -1,
      /* Failed during initialization. */
      CSOUND_INITIALIZATION = -2,
      /* Failed during performance. */
      CSOUND_PERFORMANCE = -3,
      /* Failed to allocate requested memory. */
      CSOUND_MEMORY = -4,
      /* Termination requested by SIGINT or SIGTERM. */
      CSOUND_SIGNAL = -5
    }
    CSOUND_STATUS;

  /* Compilation or performance aborted, but not as a result of an error
     (e.g. --help, or running an utility with -U). */
#define CSOUND_EXITJMP_SUCCESS  (256)

  /**
   * Flags for csoundInitialize().
   */
#define CSOUNDINIT_NO_SIGNAL_HANDLER  1
#define CSOUNDINIT_NO_ATEXIT          2

  /**
   * Constants used by the bus interface (csoundGetChannelPtr() etc.).
   */
#define CSOUND_CONTROL_CHANNEL      1
#define CSOUND_AUDIO_CHANNEL        2
#define CSOUND_STRING_CHANNEL       3

#define CSOUND_CHANNEL_TYPE_MASK    15

#define CSOUND_INPUT_CHANNEL        16
#define CSOUND_OUTPUT_CHANNEL       32

#define CSOUND_CONTROL_CHANNEL_INT  1
#define CSOUND_CONTROL_CHANNEL_LIN  2
#define CSOUND_CONTROL_CHANNEL_EXP  3

#define CSOUND_CALLBACK_KBD_EVENT   (0x00000001U)
#define CSOUND_CALLBACK_KBD_TEXT    (0x00000002U)

  /**
   * The following constants are used with csound->FileOpen2() and
   * csound->ldmemfile2() to specify the format of a file that is being
   * opened.  This information is passed by Csound to a host's FileOpen
   * callback and does not influence the opening operation in any other
   * way. Conversion from Csound's TYP_XXX macros for audio formats to
   * CSOUND_FILETYPES values can be done with csound->type2csfiletype().
   */
  typedef enum {
    CSFTYPE_UNIFIED_CSD = 1,   /* Unified Csound document */
    CSFTYPE_ORCHESTRA,         /* the primary orc file (may be temporary) */
    CSFTYPE_SCORE,             /* the primary sco file (may be temporary)
                                  or any additional score opened by Cscore */
    CSFTYPE_ORC_INCLUDE,       /* a file #included by the orchestra */
    CSFTYPE_SCO_INCLUDE,       /* a file #included by the score */
    CSFTYPE_SCORE_OUT,         /* used for score.srt, score.xtr, cscore.out */
    CSFTYPE_SCOT,              /* Scot score input format */
    CSFTYPE_OPTIONS,           /* for .csoundrc and -@ flag */
    CSFTYPE_EXTRACT_PARMS,     /* extraction file specified by -x */

    /* audio file types that Csound can write (10-19) or read */
    CSFTYPE_RAW_AUDIO,
    CSFTYPE_IRCAM,
    CSFTYPE_AIFF,
    CSFTYPE_AIFC,
    CSFTYPE_WAVE,
    CSFTYPE_AU,
    CSFTYPE_SD2,
    CSFTYPE_W64,
    CSFTYPE_WAVEX,
    CSFTYPE_FLAC,
    CSFTYPE_CAF,
    CSFTYPE_WVE,
    CSFTYPE_OGG,
    CSFTYPE_MPC2K,
    CSFTYPE_RF64,
    CSFTYPE_AVR,
    CSFTYPE_HTK,
    CSFTYPE_MAT4,
    CSFTYPE_MAT5,
    CSFTYPE_NIST,
    CSFTYPE_PAF,
    CSFTYPE_PVF,
    CSFTYPE_SDS,
    CSFTYPE_SVX,
    CSFTYPE_VOC,
    CSFTYPE_XI,
    CSFTYPE_UNKNOWN_AUDIO,     /* used when opening audio file for reading
                                  or temp file written with <CsSampleB> */

    /* miscellaneous music formats */
    CSFTYPE_SOUNDFONT,
    CSFTYPE_STD_MIDI,          /* Standard MIDI file */
    CSFTYPE_MIDI_SYSEX,        /* Raw MIDI codes, eg. SysEx dump */

    /* analysis formats */
    CSFTYPE_HETRO,
    CSFTYPE_PVC,               /* original PVOC format */
    CSFTYPE_PVCEX,             /* PVOC-EX format */
    CSFTYPE_CVANAL,
    CSFTYPE_LPC,
    CSFTYPE_ATS,
    CSFTYPE_LORIS,
    CSFTYPE_SDIF,
    CSFTYPE_HRTF,

    /* Types for plugins and the files they read/write */
    CSFTYPE_VST_PLUGIN,
    CSFTYPE_LADSPA_PLUGIN,
    CSFTYPE_SNAPSHOT,

    /* Special formats for Csound ftables or scanned synthesis
       matrices with header info */
    CSFTYPE_FTABLES_TEXT,        /* for ftsave and ftload  */
    CSFTYPE_FTABLES_BINARY,      /* for ftsave and ftload  */
    CSFTYPE_XSCANU_MATRIX,       /* for xscanu opcode  */

    /* These are for raw lists of numbers without header info */
    CSFTYPE_FLOATS_TEXT,         /* used by GEN23, GEN28, dumpk, readk */
    CSFTYPE_FLOATS_BINARY,       /* used by dumpk, readk, etc. */
    CSFTYPE_INTEGER_TEXT,        /* used by dumpk, readk, etc. */
    CSFTYPE_INTEGER_BINARY,      /* used by dumpk, readk, etc. */

    /* image file formats */
    CSFTYPE_IMAGE_PNG,

    /* For files that don't match any of the above */
    CSFTYPE_POSTSCRIPT,          /* EPS format used by graphs */
    CSFTYPE_SCRIPT_TEXT,         /* executable script files (eg. Python) */
    CSFTYPE_OTHER_TEXT,
    CSFTYPE_OTHER_BINARY,

    /* This should only be used internally by the original FileOpen()
       API call or for temp files written with <CsFileB> */
    CSFTYPE_UNKNOWN = 0
  }
    CSOUND_FILETYPES;

  /*
   * TYPE DEFINITIONS
   */

  /*
   * Forward declarations.
   */

  typedef struct CSOUND_  CSOUND;

  typedef struct windat_  WINDAT;
  typedef struct xyindat_ XYINDAT;

  /**
   * Real-time audio parameters structure
   */
  typedef struct {
    /** device name (NULL/empty: default) */
    char    *devName;
    /** device number (0-1023), 1024: default */
    int     devNum;
    /** buffer fragment size (-b) in sample frames */
    int     bufSamp_SW;
    /** total buffer size (-B) in sample frames */
    int     bufSamp_HW;
    /** number of channels */
    int     nChannels;
    /** sample format (AE_SHORT etc.) */
    int     sampleFormat;
    /** sample rate in Hz */
    float   sampleRate;
  } csRtAudioParams;

  typedef struct RTCLOCK_S {
    int_least64_t   starttime_real;
    int_least64_t   starttime_CPU;
  } RTCLOCK;

  typedef struct {
    char        *opname;
    char        *outypes;
    char        *intypes;
  } opcodeListEntry;

  typedef struct CsoundRandMTState_ {
    int         mti;
    uint32_t    mt[624];
  } CsoundRandMTState;

  typedef struct CsoundChannelListEntry_ {
    const char  *name;
    int         type;
  } CsoundChannelListEntry;

  /* PVSDATEXT is a variation on PVSDAT used in
     the pvs bus interface */
  typedef struct pvsdat_ext {
    int32           N;
    int             sliding; /* Flag to indicate sliding case */
    int32           NB;
    int32           overlap;
    int32           winsize;
    int             wintype;
    int32           format;
    uint32          framecount;
    float*          frame;
  } PVSDATEXT;

  typedef struct {
    int     size;
    MYFLT   *data;
  } TABDAT;

  typedef void (*CsoundChannelIOCallback_t)(CSOUND *csound,
                                            const char *channelName,
                                            MYFLT *channelValuePtr,
                                            int channelType);
#ifndef CSOUND_CSDL_H

  /* This pragma must come before all public function declarations */
#if (defined(macintosh) && defined(__MWERKS__))
#  pragma export on
#endif

  /*
   * INSTANTIATION
   */

  /**
   * Initialise Csound library; should be called once before creating
   * any Csound instances.
   * Return value is zero on success, positive if initialisation was
   * done already, and negative on error.
   */
  PUBLIC int csoundInitialize(int *argc, char ***argv, int flags);

  /**
   * Creates an instance of Csound.
   * Returns an opaque pointer that must be passed to most Csound API functions.
   * The hostData parameter can be NULL, or it can be a pointer to any sort of
   * data; this pointer can be accessed from the Csound instance that is passed
   * to callback routines.
   */
  PUBLIC CSOUND *csoundCreate(void *hostData);

  /**
   * Reset and prepare an instance of Csound for compilation.
   * Returns CSOUND_SUCCESS on success, and CSOUND_ERROR or
   * CSOUND_MEMORY if an error occured.
   */
  PUBLIC int csoundPreCompile(CSOUND *);

  /**
   * csoundInitializeCscore() prepares an instance of Csound for Cscore
   * processing outside of running an orchestra (i.e. "standalone Cscore").
   * It is an alternative to csoundPreCompile(), csoundCompile(), and
   * csoundPerform*() and should not be used with these functions.
   * You must call this function before using the interface in "cscore.h"
   * when you do not wish to compile an orchestra.
   * Pass it the already open FILE* pointers to the input and
   * output score files.
   * It returns CSOUND_SUCCESS on success and CSOUND_INITIALIZATION or other
   * error code if it fails.
   */
  PUBLIC int csoundInitializeCscore(CSOUND *, FILE *insco, FILE *outsco);

  /**
   * Returns a pointer to the requested interface, if available, in the
   * interface argument, and its version number, in the version argument.
   * Returns 0 for success.
   */
  PUBLIC int csoundQueryInterface(const char *name, void **iface, int *version);

  /**
   * Destroys an instance of Csound.
   */
  PUBLIC void csoundDestroy(CSOUND *);

  /**
   * Returns the version number times 1000 (5.00.0 = 5000).
   */
  PUBLIC int csoundGetVersion(void);

  /**
   * Returns the API version number times 100 (1.00 = 100).
   */
  PUBLIC int csoundGetAPIVersion(void);

  /**
   * Returns host data.
   */
  PUBLIC void *csoundGetHostData(CSOUND *);

  /**
   * Sets host data.
   */
  PUBLIC void csoundSetHostData(CSOUND *, void *hostData);

  /**
   * Get pointer to the value of environment variable 'name', searching
   * in this order: local environment of 'csound' (if not NULL), variables
   * set with csoundSetGlobalEnv(), and system environment variables.
   * If 'csound' is not NULL, should be called after csoundPreCompile()
   * or csoundCompile().
   * Return value is NULL if the variable is not set.
   */
  PUBLIC const char *csoundGetEnv(CSOUND *csound, const char *name);

  /**
   * Set the global value of environment variable 'name' to 'value',
   * or delete variable if 'value' is NULL.
   * It is not safe to call this function while any Csound instances
   * are active.
   * Returns zero on success.
   */
  PUBLIC int csoundSetGlobalEnv(const char *name, const char *value);

  /*
   * PERFORMANCE
   */

  /**
   * Compiles Csound input files (such as an orchestra and score)
   * as directed by the supplied command-line arguments,
   * but does not perform them. Returns a non-zero error code on failure.
   * In this (host-driven) mode, the sequence of calls should be as follows:
   * /code
   *       csoundCompile(csound, argc, argv);
   *       while (!csoundPerformBuffer(csound));
   *       csoundCleanup(csound);
   *       csoundReset(csound);
   * /endcode
   */
  PUBLIC int csoundCompile(CSOUND *, int argc, char **argv);

  /**
   * Compiles Csound directly from an orchestra and score strings (score can be NULL) 
   * with options given as the supplied command-line arguments 
   * but does not perform them. Returns a non-zero error code on failure.
   */
  PUBLIC int csoundCompileFromStrings(CSOUND *, char *orchst, char *scorst, int argc, char **argv);

  /**
   * Senses input events and performs audio output until the end of score
   * is reached (positive return value), an error occurs (negative return
   * value), or performance is stopped by calling csoundStop() from another
   * thread (zero return value).
   * Note that csoundCompile must be called first.
   * In the case of zero return value, csoundPerform() can be called again
   * to continue the stopped performance. Otherwise, csoundReset() should be
   * called to clean up after the finished or failed performance.
   */
  PUBLIC int csoundPerform(CSOUND *);

  /**
   * Senses input events, and performs one control sample worth (ksmps) of
   * audio output.
   * Note that csoundCompile must be called first.
   * Returns false during performance, and true when performance is finished.
   * If called until it returns true, will perform an entire score.
   * Enables external software to control the execution of Csound,
   * and to synchronize performance with audio input and output.
   */
  PUBLIC int csoundPerformKsmps(CSOUND *);

  /**
   * Senses input events, and performs one control sample worth (ksmps) of
   * audio output.
   * Note that csoundCompile must be called first.
   * Performs audio whether or not the Csound score has finished.
   * Enables external software to control the execution of Csound,
   * and to synchronize performance with audio input and output.
   */
  PUBLIC int csoundPerformKsmpsAbsolute(CSOUND *);

  /**
   * Performs Csound, sensing real-time and score events
   * and processing one buffer's worth (-b frames) of interleaved audio.
   * Returns a pointer to the new output audio in 'outputAudio'
   * Note that csoundCompile must be called first, then call
   * csoundGetOutputBuffer() and csoundGetInputBuffer() to get the pointer
   * to csound's I/O buffers.
   * Returns false during performance, and true when performance is finished.
   */
  PUBLIC int csoundPerformBuffer(CSOUND *);

  /**
   * Stops a csoundPerform() running in another thread. Note that it is
   * not guaranteed that csoundPerform() has already stopped when this
   * function returns.
   */
  PUBLIC void csoundStop(CSOUND *);

  /**
   * Finds th elist of named gens
   */
  PUBLIC void *csoundGetNamedGens(CSOUND *);

  /**
   * Prints information about the end of a performance, and closes audio
   * and MIDI devices.
   * Note: after calling csoundCleanup(), the operation of the perform
   * functions is undefined.
   */
  PUBLIC int csoundCleanup(CSOUND *);

  /**
   * Resets all internal memory and state in preparation for a new performance.
   * Enables external software to run successive Csound performances
   * without reloading Csound. Implies csoundCleanup(), unless already called.
   */
  PUBLIC void csoundReset(CSOUND *);

  /*
   * ATTRIBUTES
   */

  /**
   * Returns the number of audio sample frames per second.
   */
  PUBLIC MYFLT csoundGetSr(CSOUND *);

  /**
   * Returns the number of control samples per second.
   */
  PUBLIC MYFLT csoundGetKr(CSOUND *);

  /**
   * Returns the number of audio sample frames per control sample.
   */
  PUBLIC int csoundGetKsmps(CSOUND *);

  /**
   * Returns the number of audio output channels.
   */
  PUBLIC int csoundGetNchnls(CSOUND *);

  /**
   * Returns the 0dBFS level of the spin/spout buffers.
   */
  PUBLIC MYFLT csoundGet0dBFS(CSOUND *);

  /**
   * Returns the number of bytes allocated for a string variable
   * (the actual length is one less because of the null character
   * at the end of the string). Should be called after csoundCompile().
   */
  PUBLIC int csoundGetStrVarMaxLen(CSOUND *);

  /**
   * Returns the sample format.
   */
  PUBLIC int csoundGetSampleFormat(CSOUND *);

  /**
   * Returns the size in bytes of a single sample.
   */
  PUBLIC int csoundGetSampleSize(CSOUND *);

  /**
   * Returns the number of samples in Csound's input buffer.
   */
  PUBLIC long csoundGetInputBufferSize(CSOUND *);

  /**
   * Returns the number of samples in Csound's output buffer.
   */
  PUBLIC long csoundGetOutputBufferSize(CSOUND *);

  /**
   * Returns the address of the Csound audio input buffer.
   * Enables external software to write audio into Csound before calling
   * csoundPerformBuffer.
   */
  PUBLIC MYFLT *csoundGetInputBuffer(CSOUND *);

  /**
   * Returns the address of the Csound audio output buffer.
   * Enables external software to read audio from Csound after calling
   * csoundPerformBuffer.
   */
  PUBLIC MYFLT *csoundGetOutputBuffer(CSOUND *);

  /**
   * Returns the address of the Csound audio input working buffer (spin).
   * Enables external software to write audio into Csound before calling
   * csoundPerformKsmps.
   */
  PUBLIC MYFLT *csoundGetSpin(CSOUND *);

  /**
   * Adds the indicated sample into the audio input woriing buffer (spin);
   * this only ever makes sense before calling csoundPerformKsmps().
   * The frame and channel must be in bounds relative to ksmps and nchnls.
   */
  PUBLIC void csoundAddSpinSample(CSOUND *csound,
                                  int frame, int channel, MYFLT sample);

  /**
   * Returns the address of the Csound audio output working buffer (spout).
   * Enables external software to read audio from Csound after calling
   * csoundPerformKsmps.
   */
  PUBLIC MYFLT *csoundGetSpout(CSOUND *csound);

  /**
   * Returns the indicated sample from the Csound audio output
   * working buffer (spout); only ever makes sense after calling
   * csoundPerformKsmps().  The frame and channel must be in bounds
   * relative to ksmps and nchnls.
   */
  PUBLIC MYFLT csoundGetSpoutSample(CSOUND *csound, int frame, int channel);

  /**
   * Returns the output sound file name (-o).
   */
  PUBLIC const char *csoundGetOutputFileName(CSOUND *);

  /**
   * Calling this function with a non-zero 'state' value between
   * csoundPreCompile() and csoundCompile() will disable all default
   * handling of sound I/O by the Csound library, allowing the host
   * application to use the spin/spout/input/output buffers directly.
   * If 'bufSize' is greater than zero, the buffer size (-b) will be
   * set to the integer multiple of ksmps that is nearest to the value
   * specified.
   */
  PUBLIC void csoundSetHostImplementedAudioIO(CSOUND *, int state, int bufSize);

  /**
   * Returns the current score time in seconds
   * since the beginning of performance.
   */
  PUBLIC double csoundGetScoreTime(CSOUND *);

  /*
   * SCORE HANDLING
   */

  /**
   * Sets whether Csound score events are performed or not, independently
   * of real-time MIDI events (see csoundSetScorePending()).
   */
  PUBLIC int csoundIsScorePending(CSOUND *);

  /**
   * Sets whether Csound score events are performed or not (real-time
   * events will continue to be performed). Can be used by external software,
   * such as a VST host, to turn off performance of score events (while
   * continuing to perform real-time events), for example to
   * mute a Csound score while working on other tracks of a piece, or
   * to play the Csound instruments live.
   */
  PUBLIC void csoundSetScorePending(CSOUND *, int pending);

  /**
   * Returns the score time beginning at which score events will
   * actually immediately be performed (see csoundSetScoreOffsetSeconds()).
   */
  PUBLIC MYFLT csoundGetScoreOffsetSeconds(CSOUND *);

  /**
   * Csound score events prior to the specified time are not performed, and
   * performance begins immediately at the specified time (real-time events
   * will continue to be performed as they are received).
   * Can be used by external software, such as a VST host,
   * to begin score performance midway through a Csound score,
   * for example to repeat a loop in a sequencer, or to synchronize
   * other events with the Csound score.
   */
  PUBLIC void csoundSetScoreOffsetSeconds(CSOUND *, MYFLT time);

  /**
   * Rewinds a compiled Csound score to the time specified with
   * csoundSetScoreOffsetSeconds().
   */
  PUBLIC void csoundRewindScore(CSOUND *);

  /**
   * Sets an external callback for Cscore processing.
   * Pass NULL to reset to the internal cscore() function (which does nothing).
   * This callback is retained after a csoundReset() call.
   */
  PUBLIC void csoundSetCscoreCallback(CSOUND *,
                                      void (*cscoreCallback_)(CSOUND *));

  /**
   * Sorts score file 'inFile' and writes the result to 'outFile'.
   * The Csound instance should be initialised with csoundPreCompile()
   * before calling this function, and csoundReset() should be called
   * after sorting the score to clean up. On success, zero is returned.
   */
  PUBLIC int csoundScoreSort(CSOUND *, FILE *inFile, FILE *outFile);

  /**
   * Extracts from 'inFile', controlled by 'extractFile', and writes
   * the result to 'outFile'. The Csound instance should be initialised
   * with csoundPreCompile() before calling this function, and csoundReset()
   * should be called after score extraction to clean up.
   * The return value is zero on success.
   */
  PUBLIC int csoundScoreExtract(CSOUND *,
                                FILE *inFile, FILE *outFile, FILE *extractFile);

  /*
   * MESSAGES & TEXT
   */

  /**
   * Displays an informational message.
   */
  PUBLIC CS_PRINTF2 void csoundMessage(CSOUND *, const char *format, ...);

  /**
   * Print message with special attributes (see msg_attr.h for the list of
   * available attributes). With attr=0, csoundMessageS() is identical to
   * csoundMessage().
   */
  PUBLIC CS_PRINTF3 void csoundMessageS(CSOUND *,
                                        int attr, const char *format, ...);

  PUBLIC void csoundMessageV(CSOUND *,
                             int attr, const char *format, va_list args);

  /**
   * Sets a function to be called by Csound to print an informational message.
   */
  PUBLIC void csoundSetMessageCallback(CSOUND *,
                                       void (*csoundMessageCallback_)(CSOUND *,
                                                                      int attr,
                                                                      const char *format,
                                                                      va_list valist));

  /**
   * Returns the Csound message level (from 0 to 231).
   */
  PUBLIC int csoundGetMessageLevel(CSOUND *);

  /**
   * Sets the Csound message level (from 0 to 231).
   */
  PUBLIC void csoundSetMessageLevel(CSOUND *, int messageLevel);

  /**
   * Input a NULL-terminated string (as if from a console),
   * used for line events.
   */
  PUBLIC void csoundInputMessage(CSOUND *, const char *message);

  /**
   * Set the ASCII code of the most recent key pressed.
   * This value is used by the 'sensekey' opcode if a callback
   * for returning keyboard events is not set (see csoundSetCallback()).
   */
  PUBLIC void csoundKeyPress(CSOUND *, char c);

  /*
   * CONTROL AND EVENTS
   */

  /**
   * Control values are specified by a 'channelName' string.
   * Note that the 'invalue' & 'outvalue' channels can be specified by
   * either a string or a number.  If a number is specified, it will be
   * converted to a string before making the callbacks to the external
   * software.
   */

  /**
   * Called by external software to set a function for Csound to
   * fetch input control values.  The 'invalue' opcodes will
   * directly call this function. If 'channelName' starts with a
   * '$', then 'invalue' opcode is expecting a C string, to be copied
   * to 'value', with maximum size csoundGetStrVarMaxLen().
   */
  PUBLIC void csoundSetInputValueCallback(CSOUND *,
                                          void (*inputValueCalback_)(CSOUND *,
                                                                     const char *channelName,
                                                                     MYFLT *value));

  /**
   * Called by external software to set a function for Csound to
   * send output control values.  The 'outvalue' opcodes will
   * directly call this function.  If 'channelName' starts with a
   * '$', then the 'outvalue' opcode is sending a string appended
   * to channelName in the format: "$channelName$stringOutput".
   * and 'value' will be the index number into 'channelName' where
   * the stringOutput begins.
   */
  PUBLIC void csoundSetOutputValueCallback(CSOUND *,
                                           void (*outputValueCalback_)(CSOUND *,
                                                                       const char *channelName,
                                                                       MYFLT value));

  /**
   * Send a new score event. 'type' is the score event type ('a', 'i', 'q',
   * 'f', or 'e').
   * 'numFields' is the size of the pFields array.  'pFields' is an array of
   * floats with all the pfields for this event, starting with the p1 value
   * specified in pFields[0].
   */
  PUBLIC int csoundScoreEvent(CSOUND *,
                              char type, const MYFLT *pFields, long numFields);

  PUBLIC int csoundScoreEventAbsolute(CSOUND *,
                                      char type, const MYFLT *pfields, long numFields, double time_ofs);

  /*
   * MIDI
   */

  /**
   * Sets callback for opening real time MIDI input.
   */
  PUBLIC void csoundSetExternalMidiInOpenCallback(CSOUND *,
                                                  int (*func)(CSOUND *, void **userData, const char *devName));

  /**
   * Sets callback for reading from real time MIDI input.
   */
  PUBLIC void csoundSetExternalMidiReadCallback(CSOUND *,
                                                int (*func)(CSOUND *, void *userData,
                                                            unsigned char *buf, int nBytes));

  /**
   * Sets callback for closing real time MIDI input.
   */
  PUBLIC void csoundSetExternalMidiInCloseCallback(CSOUND *,
                                                   int (*func)(CSOUND *, void *userData));

  /**
   * Sets callback for opening real time MIDI output.
   */
  PUBLIC void csoundSetExternalMidiOutOpenCallback(CSOUND *,
                                                   int (*func)(CSOUND *, void **userData, const char *devName));

  /**
   * Sets callback for writing to real time MIDI output.
   */
  PUBLIC void csoundSetExternalMidiWriteCallback(CSOUND *,
                                                 int (*func)(CSOUND *, void *userData,
                                                             const unsigned char *buf, int nBytes));

  /**
   * Sets callback for closing real time MIDI output.
   */
  PUBLIC void csoundSetExternalMidiOutCloseCallback(CSOUND *,
                                                    int (*func)(CSOUND *, void *userData));

  /**
   * Sets callback for converting MIDI error codes to strings.
   */
  PUBLIC void csoundSetExternalMidiErrorStringCallback(CSOUND *,
                                                       const char *(*func)(int));

  /*
   * FUNCTION TABLE DISPLAY
   */

  /**
   * Tells Csound whether external graphic table display is supported.
   * Returns the previously set value (initially zero).
   */
  PUBLIC int csoundSetIsGraphable(CSOUND *, int isGraphable);

  /**
   * Called by external software to set Csound's MakeGraph function.
   */
  PUBLIC void csoundSetMakeGraphCallback(CSOUND *,
                                         void (*makeGraphCallback_)(CSOUND *,
                                                                    WINDAT *windat,
                                                                    const char *name));

  /**
   * Called by external software to set Csound's DrawGraph function.
   */
  PUBLIC void csoundSetDrawGraphCallback(CSOUND *,
                                         void (*drawGraphCallback_)(CSOUND *,
                                                                    WINDAT *windat));

  /**
   * Called by external software to set Csound's KillGraph function.
   */
  PUBLIC void csoundSetKillGraphCallback(CSOUND *,
                                         void (*killGraphCallback_)(CSOUND *,
                                                                    WINDAT *windat));

  /**
   * Called by external software to set Csound's MakeXYin function.
   */
  PUBLIC void csoundSetMakeXYinCallback(CSOUND *,
                                        void (*makeXYinCallback_)(CSOUND *, XYINDAT *,
                                                                  MYFLT x, MYFLT y));

  /**
   * Called by external software to set Csound's ReadXYin function.
   */
  PUBLIC void csoundSetReadXYinCallback(CSOUND *,
                                        void (*readXYinCallback_)(CSOUND *, XYINDAT *));

  /**
   * Called by external software to set Csound's KillXYin function.
   */
  PUBLIC void csoundSetKillXYinCallback(CSOUND *,
                                        void (*killXYinCallback_)(CSOUND *, XYINDAT *));

  /**
   * Called by external software to set Csound's ExitGraph function.
   */
  PUBLIC void csoundSetExitGraphCallback(CSOUND *,
                                         int (*exitGraphCallback_)(CSOUND *));

  /*
   * OPCODES
   */

  /**
   * Gets an alphabetically sorted list of all opcodes.
   * Should be called after externals are loaded by csoundCompile().
   * Returns the number of opcodes, or a negative error code on failure.
   * Make sure to call csoundDisposeOpcodeList() when done with the list.
   */
  PUBLIC int csoundNewOpcodeList(CSOUND *, opcodeListEntry **opcodelist);

  /**
   * Releases an opcode list.
   */
  PUBLIC void csoundDisposeOpcodeList(CSOUND *, opcodeListEntry *opcodelist);

  /**
   * Appends an opcode implemented by external software
   * to Csound's internal opcode list.
   * The opcode list is extended by one slot,
   * and the parameters are copied into the new slot.
   * Returns zero on success.
   */
  PUBLIC int csoundAppendOpcode(CSOUND *, const char *opname,
                                int dsblksiz, int thread,
                                const char *outypes, const char *intypes,
                                int (*iopadr)(CSOUND *, void *),
                                int (*kopadr)(CSOUND *, void *),
                                int (*aopadr)(CSOUND *, void *));

  /*
   * MISCELLANEOUS FUNCTIONS
   */

  /**
   * Platform-independent function to load a shared library.
   */
  PUBLIC int csoundOpenLibrary(void **library, const char *libraryPath);

  /**
   * Platform-independent function to unload a shared library.
   */
  PUBLIC int csoundCloseLibrary(void *library);

  /**
   * Platform-independent function to get a symbol address in a shared library.
   */
  PUBLIC void *csoundGetLibrarySymbol(void *library, const char *symbolName);

  /**
   * Called by external software to set a function for checking system
   * events, yielding cpu time for coopertative multitasking, etc.
   * This function is optional. It is often used as a way to 'turn off'
   * Csound, allowing it to exit gracefully. In addition, some operations
   * like utility analysis routines are not reentrant and you should use
   * this function to do any kind of updating during the operation.
   * Returns an 'OK to continue' boolean.
   */
  PUBLIC void csoundSetYieldCallback(CSOUND *, int (*yieldCallback_)(CSOUND *));

  /*
   * REAL-TIME AUDIO PLAY AND RECORD
   */

  /**
   * Sets a function to be called by Csound for opening real-time
   * audio playback.
   */
  PUBLIC void csoundSetPlayopenCallback(CSOUND *,
                                        int (*playopen__)(CSOUND *,
                                                          const csRtAudioParams *parm));

  /**
   * Sets a function to be called by Csound for performing real-time
   * audio playback.
   */
  PUBLIC void csoundSetRtplayCallback(CSOUND *,
                                      void (*rtplay__)(CSOUND *,
                                                       const MYFLT *outBuf, int nbytes));

  /**
   * Sets a function to be called by Csound for opening real-time
   * audio recording.
   */
  PUBLIC void csoundSetRecopenCallback(CSOUND *,
                                       int (*recopen_)(CSOUND *,
                                                       const csRtAudioParams *parm));

  /**
   * Sets a function to be called by Csound for performing real-time
   * audio recording.
   */
  PUBLIC void csoundSetRtrecordCallback(CSOUND *,
                                        int (*rtrecord__)(CSOUND *,
                                                          MYFLT *inBuf, int nbytes));

  /**
   * Sets a function to be called by Csound for closing real-time
   * audio playback and recording.
   */
  PUBLIC void csoundSetRtcloseCallback(CSOUND *, void (*rtclose__)(CSOUND *));

  /**
   * Returns whether Csound is in debug mode.
   */
  PUBLIC int csoundGetDebug(CSOUND *);

  /**
   * Sets whether Csound is in debug mode.
   */
  PUBLIC void csoundSetDebug(CSOUND *, int debug);

  /**
   * Returns the length of a function table (not including the guard point),
   * or -1 if the table does not exist.
   */
  PUBLIC int csoundTableLength(CSOUND *, int table);

  /**
   * Returns the value of a slot in a function table.
   * The table number and index are assumed to be valid.
   */
  PUBLIC MYFLT csoundTableGet(CSOUND *, int table, int index);

  /**
   * Sets the value of a slot in a function table.
   * The table number and index are assumed to be valid.
   */
  PUBLIC void csoundTableSet(CSOUND *, int table, int index, MYFLT value);

  /**
   * Stores pointer to function table 'tableNum' in *tablePtr,
   * and returns the table length (not including the guard point).
   * If the table does not exist, *tablePtr is set to NULL and
   * -1 is returned.
   */
  PUBLIC int csoundGetTable(CSOUND *, MYFLT **tablePtr, int tableNum);

  /**
   * Creates and starts a new thread of execution.
   * Returns an opaque pointer that represents the thread on success,
   * or NULL for failure.
   * The userdata pointer is passed to the thread routine.
   */
  PUBLIC void *csoundCreateThread(uintptr_t (*threadRoutine)(void *),
                                  void *userdata);

  /**
   * Returns the ID of the currently executing thread,
   * or NULL for failure.
   *
   * NOTE: The return value can be used as a pointer
   * to a thread object, but it should not be compared
   * as a pointer. The pointed to values should be compared,
   * and the user must free the pointer after use.
   */
  PUBLIC void *csoundGetCurrentThreadId(void);

  /**
   * Waits until the indicated thread's routine has finished.
   * Returns the value returned by the thread routine.
   */
  PUBLIC uintptr_t csoundJoinThread(void *thread);

  /**
   * Runs an external command with the arguments specified in 'argv'.
   * argv[0] is the name of the program to execute (if not a full path
   * file name, it is searched in the directories defined by the PATH
   * environment variable). The list of arguments should be terminated
   * by a NULL pointer.
   * If 'noWait' is zero, the function waits until the external program
   * finishes, otherwise it returns immediately. In the first case, a
   * non-negative return value is the exit status of the command (0 to
   * 255), otherwise it is the PID of the newly created process.
   * On error, a negative value is returned.
   */
  PUBLIC long csoundRunCommand(const char *const *argv, int noWait);

  /**
   * Creates and returns a monitor object, or NULL if not successful.
   * The object is initially in signaled (notified) state.
   */
  PUBLIC void *csoundCreateThreadLock(void);

  /**
   * Waits on the indicated monitor object for the indicated period.
   * The function returns either when the monitor object is notified,
   * or when the period has elapsed, whichever is sooner; in the first case,
   * zero is returned.
   * If 'milliseconds' is zero and the object is not notified, the function
   * will return immediately with a non-zero status.
   */
  PUBLIC int csoundWaitThreadLock(void *lock, size_t milliseconds);

  /**
   * Waits on the indicated monitor object until it is notified.
   * This function is similar to csoundWaitThreadLock() with an infinite
   * wait time, but may be more efficient.
   */
  PUBLIC void csoundWaitThreadLockNoTimeout(void *lock);

  /**
   * Notifies the indicated monitor object.
   */
  PUBLIC void csoundNotifyThreadLock(void *lock);

  /**
   * Destroys the indicated monitor object.
   */
  PUBLIC void csoundDestroyThreadLock(void *lock);

  /**
   * Creates and returns a mutex object, or NULL if not successful.
   * Mutexes can be faster than the more general purpose monitor objects
   * returned by csoundCreateThreadLock() on some platforms, and can also
   * be recursive, but the result of unlocking a mutex that is owned by
   * another thread or is not locked is undefined.
   * If 'isRecursive' is non-zero, the mutex can be re-locked multiple
   * times by the same thread, requiring an equal number of unlock calls;
   * otherwise, attempting to re-lock the mutex results in undefined
   * behavior.
   * Note: the handles returned by csoundCreateThreadLock() and
   * csoundCreateMutex() are not compatible.
   */
  PUBLIC void *csoundCreateMutex(int isRecursive);

  /**
   * Acquires the indicated mutex object; if it is already in use by
   * another thread, the function waits until the mutex is released by
   * the other thread.
   */
  PUBLIC void csoundLockMutex(void *mutex_);

  /**
   * Acquires the indicated mutex object and returns zero, unless it is
   * already in use by another thread, in which case a non-zero value is
   * returned immediately, rather than waiting until the mutex becomes
   * available.
   * Note: this function may be unimplemented on Windows.
   */
  PUBLIC int csoundLockMutexNoWait(void *mutex_);

  /**
   * Releases the indicated mutex object, which should be owned by
   * the current thread, otherwise the operation of this function is
   * undefined. A recursive mutex needs to be unlocked as many times
   * as it was locked previously.
   */
  PUBLIC void csoundUnlockMutex(void *mutex_);

  /**
   * Destroys the indicated mutex object. Destroying a mutex that
   * is currently owned by a thread results in undefined behavior.
   */
  PUBLIC void csoundDestroyMutex(void *mutex_);


  /**
   * Create a Thread Barrier. Max value parameter should be equal to
   * number of child threads using the barrier plus one for the
   * master thread */

  PUBLIC void *csoundCreateBarrier(unsigned int max);

  /**
   * Destroy a Thread Barrier.
   */
  PUBLIC int csoundDestroyBarrier(void *barrier);

  /**
   * Wait on the thread barrier.
   */
  PUBLIC int csoundWaitBarrier(void *barrier);

  /**
   * Waits for at least the specified number of milliseconds,
   * yielding the CPU to other threads.
   */
  PUBLIC void csoundSleep(size_t milliseconds);

  /**
   * Initialise a timer structure.
   */
  PUBLIC void csoundInitTimerStruct(RTCLOCK *);

  /**
   * Return the elapsed real time (in seconds) since the specified timer
   * structure was initialised.
   */
  PUBLIC double csoundGetRealTime(RTCLOCK *);

  /**
   * Return the elapsed CPU time (in seconds) since the specified timer
   * structure was initialised.
   */
  PUBLIC double csoundGetCPUTime(RTCLOCK *);

  /**
   * Return a 32-bit unsigned integer to be used as seed from current time.
   */
  PUBLIC uint32_t csoundGetRandomSeedFromTime(void);

  /**
   * Set language to 'lang_code' (lang_code can be for example
   * CSLANGUAGE_ENGLISH_UK or CSLANGUAGE_FRENCH or many others,
   * see n_getstr.h for the list of languages). This affects all
   * Csound instances running in the address space of the current
   * process. The special language code CSLANGUAGE_DEFAULT can be
   * used to disable translation of messages and free all memory
   * allocated by a previous call to csoundSetLanguage().
   * csoundSetLanguage() loads all files for the selected language
   * from the directory specified by the CSSTRNGS environment
   * variable.
   */
  PUBLIC void csoundSetLanguage(cslanguage_t lang_code);

  /**
   * Translate string 's' to the current language, and return
   * pointer to the translated message. This may be the same as
   * 's' if language was set to CSLANGUAGE_DEFAULT.
   */
  PUBLIC char *csoundLocalizeString(const char *s);

  /**
   * Allocate nbytes bytes of memory that can be accessed later by calling
   * csoundQueryGlobalVariable() with the specified name; the space is
   * cleared to zero.
   * Returns CSOUND_SUCCESS on success, CSOUND_ERROR in case of invalid
   * parameters (zero nbytes, invalid or already used name), or
   * CSOUND_MEMORY if there is not enough memory.
   */
  PUBLIC int csoundCreateGlobalVariable(CSOUND *,
                                        const char *name, size_t nbytes);

  /**
   * Get pointer to space allocated with the name "name".
   * Returns NULL if the specified name is not defined.
   */
  PUBLIC void *csoundQueryGlobalVariable(CSOUND *, const char *name);

  /**
   * This function is the same as csoundQueryGlobalVariable(), except the
   * variable is assumed to exist and no error checking is done.
   * Faster, but may crash or return an invalid pointer if 'name' is
   * not defined.
   */
  PUBLIC void *csoundQueryGlobalVariableNoCheck(CSOUND *, const char *name);

  /**
   * Free memory allocated for "name" and remove "name" from the database.
   * Return value is CSOUND_SUCCESS on success, or CSOUND_ERROR if the name is
   * not defined.
   */
  PUBLIC int csoundDestroyGlobalVariable(CSOUND *, const char *name);

  /**
   * Return the size of MYFLT in bytes.
   */
  PUBLIC int csoundGetSizeOfMYFLT(void);

  /**
   * Return pointer to user data pointer for real time audio input.
   */
  PUBLIC void **csoundGetRtRecordUserData(CSOUND *);

  /**
   * Return pointer to user data pointer for real time audio output.
   */
  PUBLIC void **csoundGetRtPlayUserData(CSOUND *);

  /**
   * Register a function to be called once in every control period
   * by sensevents(). Any number of functions may be registered,
   * and will be called in the order of registration.
   * The callback function takes two arguments: the Csound instance
   * pointer, and the userData pointer as passed to this function.
   * Returns zero on success.
   */
  PUBLIC int csoundRegisterSenseEventCallback(CSOUND *,
                                              void (*func)(CSOUND *, void *),
                                              void *userData);

  /**
   * Run utility with the specified name and command line arguments.
   * Should be called after loading utility plugins with csoundPreCompile();
   * use csoundReset() to clean up after calling this function.
   * Returns zero if the utility was run successfully.
   */
  PUBLIC int csoundRunUtility(CSOUND *, const char *name,
                              int argc, char **argv);

  /**
   * Returns a NULL terminated list of registered utility names.
   * The caller is responsible for freeing the returned array with
   * csoundDeleteUtilityList(), however, the names should not be
   * changed or freed.
   * The return value may be NULL in case of an error.
   */
  PUBLIC char **csoundListUtilities(CSOUND *);

  /**
   * Releases an utility list previously returned by csoundListUtilities().
   */
  PUBLIC void csoundDeleteUtilityList(CSOUND *, char **lst);

  /**
   * Get utility description.
   * Returns NULL if the utility was not found, or it has no description,
   * or an error occured.
   */
  PUBLIC const char *csoundGetUtilityDescription(CSOUND *,
                                                 const char *utilName);

  /**
   * Stores a pointer to the specified channel of the bus in *p,
   * creating the channel first if it does not exist yet.
   * 'type' must be the bitwise OR of exactly one of the following values,
   *   CSOUND_CONTROL_CHANNEL
   *     control data (one MYFLT value)
   *   CSOUND_AUDIO_CHANNEL
   *     audio data (csoundGetKsmps(csound) MYFLT values)
   *   CSOUND_STRING_CHANNEL
   *     string data (MYFLT values with enough space to store
   *     csoundGetStrVarMaxLen(csound) characters, including the
   *     NULL character at the end of the string)
   * and at least one of these:
   *   CSOUND_INPUT_CHANNEL
   *   CSOUND_OUTPUT_CHANNEL
   * If the channel already exists, it must match the data type (control,
   * audio, or string), however, the input/output bits are OR'd with the
   * new value. Note that audio and string channels can only be created
   * after calling csoundCompile(), because the storage size is not known
   * until then.
   * Return value is zero on success, or a negative error code,
   *   CSOUND_MEMORY  there is not enough memory for allocating the channel
   *   CSOUND_ERROR   the specified name or type is invalid
   * or, if a channel with the same name but incompatible type already exists,
   * the type of the existing channel. In the case of any non-zero return
   * value, *p is set to NULL.
   * Note: to find out the type of a channel without actually creating or
   * changing it, set 'type' to zero, so that the return value will be either
   * the type of the channel, or CSOUND_ERROR if it does not exist.
   */
  PUBLIC int csoundGetChannelPtr(CSOUND *,
                                 MYFLT **p, const char *name, int type);

  /**
   * Returns a list of allocated channels in *lst. A CsoundChannelListEntry
   * structure contains the name and type of a channel, with the type having
   * the same format as in the case of csoundGetChannelPtr().
   * The return value is the number of channels, which may be zero if there
   * are none, or CSOUND_MEMORY if there is not enough memory for allocating
   * the list. In the case of no channels or an error, *lst is set to NULL.
   * Notes: the caller is responsible for freeing the list returned in *lst
   * with csoundDeleteChannelList(). The name pointers may become invalid
   * after calling csoundReset().
   */
  PUBLIC int csoundListChannels(CSOUND *, CsoundChannelListEntry **lst);

  /**
   * Releases a channel list previously returned by csoundListChannels().
   */
  PUBLIC void csoundDeleteChannelList(CSOUND *, CsoundChannelListEntry *lst);

  /**
   * Sets special parameters for a control channel. The parameters are:
   *   type:  must be one of CSOUND_CONTROL_CHANNEL_INT,
   *          CSOUND_CONTROL_CHANNEL_LIN, or CSOUND_CONTROL_CHANNEL_EXP for
   *          integer, linear, or exponential channel data, respectively,
   *          or zero to delete any previously assigned parameter information
   *   dflt:  the control value that is assumed to be the default, should be
   *          greater than or equal to 'min', and less than or equal to 'max'
   *   min:   the minimum value expected; if the control type is exponential,
   *          it must be non-zero
   *   max:   the maximum value expected, should be greater than 'min';
   *          if the control type is exponential, it must be non-zero and
   *          match the sign of 'min'
   * Returns zero on success, or a non-zero error code on failure:
   *   CSOUND_ERROR:  the channel does not exist, is not a control channel,
   *                  or the specified parameters are invalid
   *   CSOUND_MEMORY: could not allocate memory
   */
  PUBLIC int csoundSetControlChannelParams(CSOUND *, const char *name,
                                           int type, MYFLT dflt,
                                           MYFLT min, MYFLT max);

  /**
   * Returns special parameters (assuming there are any) of a control channel,
   * previously set with csoundSetControlChannelParams().
   * If the channel exists, is a control channel, and has the special parameters
   * assigned, then the default, minimum, and maximum value is stored in *dflt,
   * *min, and *max, respectively, and a positive value that is one of
   * CSOUND_CONTROL_CHANNEL_INT, CSOUND_CONTROL_CHANNEL_LIN, and
   * CSOUND_CONTROL_CHANNEL_EXP is returned.
   * In any other case, *dflt, *min, and *max are not changed, and the return
   * value is zero if the channel exists, is a control channel, but has no
   * special parameters set; otherwise, a negative error code is returned.
   */
  PUBLIC int csoundGetControlChannelParams(CSOUND *, const char *name,
                                           MYFLT *dflt, MYFLT *min, MYFLT *max);

  /**
   * Sets callback function to be called by the opcodes 'chnsend' and
   * 'chnrecv'. Should be called between csoundPreCompile() and
   * csoundCompile().
   * The callback function takes the following arguments:
   *   CSOUND *csound
   *     Csound instance pointer
   *   const char *channelName
   *     the channel name
   *   MYFLT *channelValuePtr
   *     pointer to the channel value. Control channels are a single MYFLT
   *     value, while audio channels are an array of csoundGetKsmps(csound)
   *     MYFLT values. In the case of string channels, the pointer should be
   *     cast to char *, and points to a buffer of
   *     csoundGetStrVarMaxLen(csound) bytes
   *   int channelType
   *     bitwise OR of the channel type (CSOUND_CONTROL_CHANNEL,
   *     CSOUND_AUDIO_CHANNEL, or CSOUND_STRING_CHANNEL; use
   *     channelType & CSOUND_CHANNEL_TYPE_MASK to extract the channel
   *     type), and either CSOUND_INPUT_CHANNEL or CSOUND_OUTPUT_CHANNEL
   *     to indicate the direction of the data transfer
   * The callback is not preserved on csoundReset().
   */
  PUBLIC void csoundSetChannelIOCallback(CSOUND *,
                                         CsoundChannelIOCallback_t func);

  /**
   * Recovers a pointer to a lock for the specified channel of the bus in *p
   * which must exist.
   * 'type' must be the bitwise OR of exactly one of the following values,
   *   CSOUND_CONTROL_CHANNEL
   *     control data (one MYFLT value)
   *   CSOUND_AUDIO_CHANNEL
   *     audio data (csoundGetKsmps(csound) MYFLT values)
   *   CSOUND_STRING_CHANNEL
   *     string data (MYFLT values with enough space to store
   *     csoundGetStrVarMaxLen(csound) characters, including the
   *     NULL character at the end of the string)
   * and at least one of these:
   *   CSOUND_INPUT_CHANNEL
   *   CSOUND_OUTPUT_CHANNEL
   * Return value is the address of the lock
   */
  PUBLIC int *csoundGetChannelLock(CSOUND *,
                                   const char *name, int type);

  /**
   * Simple linear congruential random number generator:
   *   (*seedVal) = (*seedVal) * 742938285 % 2147483647
   * the initial value of *seedVal must be in the range 1 to 2147483646.
   * Returns the next number from the pseudo-random sequence,
   * in the range 1 to 2147483646.
   */
  PUBLIC int csoundRand31(int *seedVal);

  /**
   * Initialise Mersenne Twister (MT19937) random number generator,
   * using 'keyLength' unsigned 32 bit values from 'initKey' as seed.
   * If the array is NULL, the length parameter is used for seeding.
   */
  PUBLIC void csoundSeedRandMT(CsoundRandMTState *p,
                               const uint32_t *initKey, uint32_t keyLength);

  /**
   * Returns next random number from MT19937 generator.
   * The PRNG must be initialised first by calling csoundSeedRandMT().
   */
  PUBLIC uint32_t csoundRandMT(CsoundRandMTState *p);

  /**
   * Sends a MYFLT value to the chani opcode (k-rate) at index 'n'.
   * The bus is automatically extended if 'n' exceeds any previously used
   * index value, clearing new locations to zero.
   * Returns zero on success, CSOUND_ERROR if the index is invalid, and
   * CSOUND_MEMORY if there is not enough memory to extend the bus.
   */
  PUBLIC int csoundChanIKSet(CSOUND *, MYFLT value, int n);

  /**
   * Receives a MYFLT value from the chano opcode (k-rate) at index 'n'.
   * The bus is automatically extended if 'n' exceeds any previously used
   * index value, clearing new locations to zero.
   * Returns zero on success, CSOUND_ERROR if the index is invalid, and
   * CSOUND_MEMORY if there is not enough memory to extend the bus.
   */
  PUBLIC int csoundChanOKGet(CSOUND *, MYFLT *value, int n);

  /**
   * Sends ksmps MYFLT values to the chani opcode (a-rate) at index 'n'.
   * The bus is automatically extended if 'n' exceeds any previously used
   * index value, clearing new locations to zero.
   * Returns zero on success, CSOUND_ERROR if the index is invalid, and
   * CSOUND_MEMORY if there is not enough memory to extend the bus.
   */
  PUBLIC int csoundChanIASet(CSOUND *, const MYFLT *value, int n);

  /**
   * Receives ksmps MYFLT values from the chano opcode (a-rate) at index 'n'.
   * The bus is automatically extended if 'n' exceeds any previously used
   * index value, clearing new locations to zero.
   * Returns zero on success, CSOUND_ERROR if the index is invalid, and
   * CSOUND_MEMORY if there is not enough memory to extend the bus.
   */
  PUBLIC int csoundChanOAGet(CSOUND *, MYFLT *value, int n);

  /**
   * Sets the chani opcode MYFLT k-rate value for the indicated channel.
   * The bus is automatically extended if the channel is greater than
   * previously used, clearing new locations to zero.
   * Returns zero on success, CSOUND_ERROR if the index is invalid,
   * and CSOUND_MEMORY if there is not enough memory to estend the bus.
   */
  PUBLIC int csoundChanIKSetValue(CSOUND *, int channel, MYFLT value);

  /**
   * Returns the chani opcode MYFLT k-rate value for the indicated channel.
   * The bus is automatically extended if the channel is greater than
   * previously used, clearing new locations to zero.
   * Returns the sample value on success, CSOUND_ERROR if the index is invalid,
   * and CSOUND_MEMORY if there is not enough memory to estend the bus
   */
  PUBLIC MYFLT csoundChanOKGetValue(CSOUND *, int channel);

  /**
   * Sets the chani opcode MYFLT a-rate value for the indicated frame
   * of the indicated channel.
   * The bus is automatically extended if the channel is greater than
   * previously used, clearing new locations to zero.
   * Returns zero on success, CSOUND_ERROR if the index is invalid,
   * and CSOUND_MEMORY if there is not enough memory to estend the bus.
   */
  PUBLIC int csoundChanIASetSample(CSOUND *,
                                   int channel, int frame, MYFLT sample);

  /**
   * Sets the chani opcode MYFLT a-rate value for the indicated frame
   * for the indicated channel.
   * The bus is automatically extended if the channel is greater than
   * previously used, clearing new locations to zero.
   * Returns the sample value on success, CSOUND_ERROR if the index is invalid,
   * and CSOUND_MEMORY if there is not enough memory to estend the bus.
   */
  PUBLIC MYFLT csoundChanOAGetSample(CSOUND *, int channel, int frame);

  /**
   * Sends a PVSDATEX fin to the pvsin opcode (f-rate) at index 'n'.
   * The bus is automatically extended if 'n' exceeds any previously used
   * index value, clearing new locations to zero.
   * Returns zero on success, CSOUND_ERROR if the index is invalid or
   * fsig framesizes are incompatible
   * CSOUND_MEMORY if there is not enough memory to extend the bus.
   */
  PUBLIC int csoundChanIASetSample(CSOUND *,
                                   int channel, int frame, MYFLT sample);

  /**
   * Sets the chani opcode MYFLT a-rate value for the indicated frame
   * for the indicated channel.
   * The bus is automatically extended if the channel is greater than
   * previously used, clearing new locations to zero.
   * Returns the sample value on success, CSOUND_ERROR if the index is invalid,
   * and CSOUND_MEMORY if there is not enough memory to estend the bus.
   */
  PUBLIC MYFLT csoundChanOAGetSample(CSOUND *, int channel, int frame);

  /**
   * Sends a PVSDATEX fin to the pvsin opcode (f-rate) at index 'n'.
   * The bus is automatically extended if 'n' exceeds any previously used
   * index value, clearing new locations to zero.
   * Returns zero on success, CSOUND_ERROR if the index is invalid or
   * fsig framesizes are incompatible
   * CSOUND_MEMORY if there is not enough memory to extend the bus.
   */
  PUBLIC int csoundPvsinSet(CSOUND *, const PVSDATEXT *fin, int n);

  /**
   * Receives a PVSDAT fout from the pvsout opcode (f-rate) at index 'n'.
   * The bus is extended if 'n' exceeds any previous value.
   * Returns zero on success, CSOUND_ERROR if the index is invalid or
   * if fsig framesizes are incompatible
   * CSOUND_MEMORY if there is not enough memory to extend the bus
   */
  PUBLIC int csoundPvsoutGet(CSOUND *csound, PVSDATEXT *fout, int n);

  /**
   * Sets general purpose callback function that will be called on various
   * events. The callback is preserved on csoundReset(), and multiple
   * callbacks may be set and will be called in reverse order of
   * registration. If the same function is set again, it is only moved
   * in the list of callbacks so that it will be called first, and the
   * user data and type mask parameters are updated. 'typeMask' can be the
   * bitwise OR of callback types for which the function should be called,
   * or zero for all types.
   * Returns zero on success, CSOUND_ERROR if the specified function
   * pointer or type mask is invalid, and CSOUND_MEMORY if there is not
   * enough memory.
   *
   * The callback function takes the following arguments:
   *   void *userData
   *     the "user data" pointer, as specified when setting the callback
   *   void *p
   *     data pointer, depending on the callback type
   *   unsigned int type
   *     callback type, can be one of the following (more may be added in
   *     future versions of Csound):
   *       CSOUND_CALLBACK_KBD_EVENT
   *       CSOUND_CALLBACK_KBD_TEXT
   *         called by the sensekey opcode to fetch key codes. The data
   *         pointer is a pointer to a single value of type 'int', for
   *         returning the key code, which can be in the range 1 to 65535,
   *         or 0 if there is no keyboard event.
   *         For CSOUND_CALLBACK_KBD_EVENT, both key press and release
   *         events should be returned (with 65536 (0x10000) added to the
   *         key code in the latter case) as unshifted ASCII codes.
   *         CSOUND_CALLBACK_KBD_TEXT expects key press events only as the
   *         actual text that is typed.
   * The return value should be zero on success, negative on error, and
   * positive if the callback was ignored (for example because the type is
   * not known).
   */
  PUBLIC int csoundSetCallback(CSOUND *, int (*func)(void *userData, void *p,
                                                     unsigned int type),
                               void *userData, unsigned int typeMask);

  /**
   * Removes a callback previously set with csoundSetCallback().
   */
  PUBLIC void csoundRemoveCallback(CSOUND *,
                                   int (*func)(void *, void *, unsigned int));



  /**
   * Creates a buffer for storing messages printed by Csound.
   * Should be called after creating a Csound instance; note that
   * the message buffer uses the host data pointer, and the buffer
   * should be freed by calling csoundDestroyMessageBuffer() before
   * deleting the Csound instance.
   * If 'toStdOut' is non-zero, the messages are also printed to
   * stdout and stderr (depending on the type of the message),
   * in addition to being stored in the buffer.
   */
  void PUBLIC csoundEnableMessageBuffer(CSOUND *csound, int toStdOut);

  /**
   * Returns the first message from the buffer.
   */
  PUBLIC const char  *csoundGetFirstMessage(CSOUND *csound);

  /**
   * Returns the attribute parameter (see msg_attr.h) of the first message
   * in the buffer.
   */
  int PUBLIC csoundGetFirstMessageAttr(CSOUND *csound);

  /**
   * Removes the first message from the buffer.
   */
  void PUBLIC csoundPopFirstMessage(CSOUND *csound);

  /**
   * Returns the number of pending messages in the buffer.
   */
  int PUBLIC csoundGetMessageCnt(CSOUND *csound);

  /**
   * Releases all memory used by the message buffer.
   */
  void PUBLIC csoundDestroyMessageBuffer(CSOUND *csound);

#ifdef never
  void PUBLIC sigcpy(MYFLT *dest, MYFLT *src, int size);
#endif

#if !defined(SWIG)
  /**
   * Sets an external callback for receiving notices whenever Csound opens
   * a file.  The callback is made after the file is successfully opened.
   * The following information is passed to the callback:
   *     char*  pathname of the file; either full or relative to current dir
   *     int    a file type code from the enumeration CSOUND_FILETYPES
   *     int    1 if Csound is writing the file, 0 if reading
   *     int    1 if a temporary file that Csound will delete; 0 if not
   *
   * Pass NULL to disable the callback.
   * This callback is retained after a csoundReset() call.
   */
  PUBLIC void csoundSetFileOpenCallback(CSOUND *p,
                                        void (*func)(CSOUND *, const char *, int, int, int));
#endif

  /* This pragma must come after all public function declarations */
#if (defined(macintosh) && defined(__MWERKS__))
#  pragma export off
#endif

#endif  /* !CSOUND_CSDL_H */

        /* typedefs, macros, and interface functions for configuration variables */
#include "cfgvar.h"
  /* message attribute definitions for csoundMessageS() and csoundMessageV() */
#include "msg_attr.h"
  /* macro definitions for Csound release, and API version */
#include "version.h"

  /**
   * Spinlocks should be used to protect shared data (not functions)
   * against races on symmetrical multiprocessor machines. These are
   * wrappers for pthreads spinlocks, and other implementations using
   * interlocked increment and decrement, or atomic compare and swap.
   */
  

#if defined(HAVE_PTHREAD_SPIN_LOCK)
  /* Note that the volatile is unnecessary as it is in the typedef 
     of pthread_spinlock_t */
  PUBLIC int csoundSpinInit(pthread_spinlock_t *spinlock);
  PUBLIC int csoundSpinLock (pthread_spinlock_t *spinlock);
  PUBLIC int csoundSpinUnLock(pthread_spinlock_t *spinlock);
  PUBLIC int csoundSpinDestroy(volatile pthread_spinlock_t *spinlock);
#else 
  PUBLIC int csoundSpinInit(volatile int32_t *lock);
  PUBLIC int csoundSpinLock(volatile int32_t *lock);
  PUBLIC int csoundSpinUnLock(volatile int32_t *lock);
  PUBLIC int csoundSpinDestroy(volatile int32_t *lock);
#endif

 /**
  * Create circular buffer with size samples
  */
  PUBLIC void *csoundCreateCircularBuffer(CSOUND *csound, int size);

 /**
  * Read from circular buffer
  * void *circular_buffer - pointer to an existing circular buffer
  * MYFLT *out - buffer with at least items samples where buffer contents will be read into
  * int items - number of samples to be read
  * returns the number of samples read (0 <= n <= items)
  */
  PUBLIC int csoundReadCircularBuffer(CSOUND *csound, void *circular_buffer, MYFLT *out, int items);

 /**
  * Write to circular buffer
  * void *circular_buffer - pointer to an existing circular buffer
  * MYFLT *inp - buffer with at least items samples to bet written into circular buffer
  * int items - number of samples to be read
  * returns the number of samples read (0 <= n <= items)
  */
  PUBLIC int csoundWriteCircularBuffer(CSOUND *csound, void *p, const MYFLT *inp, int items);

 /**
  * Free circular buffer
  */
  PUBLIC void csoundFreeCircularBuffer(CSOUND *csound, void *circularbuffer);

#ifdef __cplusplus
}
#endif

#endif  /* CSOUND_H */
