/*
    csound.hpp:

    Copyright (C) 2005 Istvan Varga, Michael Gogins

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

    As a special exception, if other files instantiate templates or
    use macros or inline functions from this file, this file does not
    by itself cause the resulting executable or library to be covered
    by the GNU Lesser General Public License. This exception does not
    however invalidate any other reasons why the library or executable
    file might be covered by the GNU Lesser General Public License.
*/

#ifndef __CSOUND_HPP__
#define __CSOUND_HPP__

#ifdef SWIG
%module csnd
%{
#include "csound.h"
  //#include "cs_glue.h"
%}
#else
#include "csound.h"
#if defined(HAVE_PTHREAD_SPIN_LOCK) && !defined(SWIG)
#include <pthread.h>
#endif
#ifdef __BUILDING_CSOUND_INTERFACES
//#include "cs_glue.h"
#endif
#endif

#ifdef SWIGPYTHON
#define MESSAGE_BUFFER_LENGTH 8192
struct PUBLIC pycbdata {
  PyObject *mfunc,*invalfunc,*outvalfunc;
  PyObject *midiinopenfunc, *midireadfunc, *midiinclosefunc;
  PyObject *hostdata;
  char messageBuffer[MESSAGE_BUFFER_LENGTH];
  int messageBufferIndex;
};
#endif

#if defined(__cplusplus)

#if defined(HAVE_PTHREAD_SPIN_LOCK) && !defined(SWIG)
struct Spinlock
{
    pthread_spinlock_t lock_;
    Spinlock()
    {
        pthread_spin_init(&lock_, PTHREAD_PROCESS_PRIVATE);
    }
    ~Spinlock()
    {
        pthread_spin_destroy(&lock_);
    }
    void lock()
    {
        pthread_spin_lock(&lock_);
    }
    void unlock()
    {
        pthread_spin_unlock(&lock_);
    }
};

struct Spinlocker
{
    Spinlock &spinlock;
    Spinlocker(Spinlock &spinlock_) : spinlock(spinlock_)
    {
        spinlock.lock();
    }
    ~Spinlocker()
    {
        spinlock.unlock();
    }
};
#endif


/**
 * C++ interface to the "C" Csound API.
 */
class PUBLIC Csound
{
protected:
  CSOUND *csound;
public:
  void *pydata;

public:
  virtual CSOUND *GetCsound()
  {
    return csound;
  }
  // csound.h interface
  virtual int PreCompile()
  {
    return csoundPreCompile(csound);
  }
  virtual int InitializeCscore(FILE *insco, FILE *outsco)
  {
    return csoundInitializeCscore(csound, insco, outsco);
  }
  virtual void *GetHostData()
  {
    return csoundGetHostData(csound);
  }
  virtual void SetHostData(void *hostData)
  {
    csoundSetHostData(csound, hostData);
  }
  virtual const char *GetEnv(const char *name)
  {
    return csoundGetEnv(csound, name);
  }
  // performance
  virtual int Compile(int argc, char **argv)
  {
    return csoundCompile(csound, argc, argv);
  }
  virtual int Compile(char *csdName)
  {
    char  *argv[3];
    argv[0] = (char*)"csound";
    argv[1] = csdName;
    argv[2] = (char*) 0;
    return csoundCompile(csound, 2, &(argv[0]));
  }
  virtual int Compile(char *orcName, char *scoName)
  {
    char  *argv[4];
    argv[0] = (char*)"csound";
    argv[1] = orcName;
    argv[2] = scoName;
    argv[3] = (char*) 0;
    return csoundCompile(csound, 3, &(argv[0]));
  }
  virtual int Compile(char *arg1, char *arg2, char *arg3)
  {
    char  *argv[5];
    argv[0] = (char*)"csound";
    argv[1] = arg1;
    argv[2] = arg2;
    argv[3] = arg3;
    argv[4] = (char*) 0;
    return csoundCompile(csound, 4, &(argv[0]));
  }
  virtual int Compile(char *arg1, char *arg2, char *arg3, char *arg4)
  {
    char  *argv[6];
    argv[0] = (char*)"csound";
    argv[1] = arg1;
    argv[2] = arg2;
    argv[3] = arg3;
    argv[4] = arg4;
    argv[5] = (char*) 0;
    return csoundCompile(csound, 5, &(argv[0]));
  }
  virtual int Compile(char *arg1, char *arg2, char *arg3,
                      char *arg4, char *arg5)
  {
    char  *argv[7];
    argv[0] = (char*)"csound";
    argv[1] = arg1;
    argv[2] = arg2;
    argv[3] = arg3;
    argv[4] = arg4;
    argv[5] = arg5;
    argv[6] = (char*) 0;
    return csoundCompile(csound, 6, &(argv[0]));
  }
  virtual int Perform()
  {
    return csoundPerform(csound);
  }
  virtual int Perform(int argc, char **argv)
  {
    int retval = csoundCompile(csound, argc, argv);
    if (!retval)
      retval = csoundPerform(csound);
    csoundCleanup(csound);
    return (retval >= 0 ? 0 : retval);
  }
  virtual int Perform(char *csdName)
  {
    char  *argv[3];
    int   retval;
    argv[0] = (char*)"csound";
    argv[1] = csdName;
    argv[2] = (char*) 0;
    if (!(retval = csoundCompile(csound, 2, &(argv[0]))))
      retval = csoundPerform(csound);
    csoundCleanup(csound);
    return (retval >= 0 ? 0 : retval);
  }
  virtual int Perform(char *orcName, char *scoName)
  {
    char  *argv[4];
    int   retval;
    argv[0] = (char*)"csound";
    argv[1] = orcName;
    argv[2] = scoName;
    argv[3] = (char*) 0;
    if (!(retval = csoundCompile(csound, 3, &(argv[0]))))
      retval = csoundPerform(csound);
    csoundCleanup(csound);
    return (retval >= 0 ? 0 : retval);
  }
  virtual int Perform(char *arg1, char *arg2, char *arg3)
  {
    char  *argv[5];
    int   retval;
    argv[0] = (char*)"csound";
    argv[1] = arg1;
    argv[2] = arg2;
    argv[3] = arg3;
    argv[4] = (char*) 0;
    if (!(retval = csoundCompile(csound, 4, &(argv[0]))))
      retval = csoundPerform(csound);
    csoundCleanup(csound);
    return (retval >= 0 ? 0 : retval);
  }
  virtual int Perform(char *arg1, char *arg2, char *arg3, char *arg4)
  {
    char  *argv[6];
    int   retval;
    argv[0] = (char*)"csound";
    argv[1] = arg1;
    argv[2] = arg2;
    argv[3] = arg3;
    argv[4] = arg4;
    argv[5] = (char*) 0;
    if (!(retval = csoundCompile(csound, 5, &(argv[0]))))
      retval = csoundPerform(csound);
    csoundCleanup(csound);
    return (retval >= 0 ? 0 : retval);
  }
  virtual int Perform(char *arg1, char *arg2, char *arg3,
                      char *arg4, char *arg5)
  {
    char  *argv[7];
    int   retval;
    argv[0] = (char*)"csound";
    argv[1] = arg1;
    argv[2] = arg2;
    argv[3] = arg3;
    argv[4] = arg4;
    argv[5] = arg5;
    argv[6] = (char*) 0;
    if (!(retval = csoundCompile(csound, 6, &(argv[0]))))
      retval = csoundPerform(csound);
    csoundCleanup(csound);
    return (retval >= 0 ? 0 : retval);
  }
  virtual int PerformKsmps()
  {
    return csoundPerformKsmps(csound);
  }
  virtual int PerformKsmpsAbsolute()
  {
    return csoundPerformKsmpsAbsolute(csound);
  }
  virtual int PerformBuffer()
  {
    return csoundPerformBuffer(csound);
  }
  virtual void Stop()
  {
    csoundStop(csound);
  }
  virtual int Cleanup()
  {
    return csoundCleanup(csound);
  }
  virtual void Reset()
  {
    csoundReset(csound);
  }
  // attributes
  virtual MYFLT GetSr()
  {
    return csoundGetSr(csound);
  }
  virtual MYFLT GetKr()
  {
    return csoundGetKr(csound);
  }
  virtual int GetKsmps()
  {
    return csoundGetKsmps(csound);
  }
  virtual int GetNchnls()
  {
    return csoundGetNchnls(csound);
  }
  virtual MYFLT Get0dBFS()
  {
    return csoundGet0dBFS(csound);
  }
  virtual int GetStrVarMaxLen()
  {
    return csoundGetStrVarMaxLen(csound);
  }
  virtual int GetSampleFormat()
  {
    return csoundGetSampleFormat(csound);
  }
  virtual int GetSampleSize()
  {
    return csoundGetSampleSize(csound);
  }
  virtual long GetInputBufferSize()
  {
    return csoundGetInputBufferSize(csound);
  }
  virtual long GetOutputBufferSize()
  {
    return csoundGetOutputBufferSize(csound);
  }
  virtual MYFLT *GetInputBuffer()
  {
    return csoundGetInputBuffer(csound);
  }
  virtual MYFLT *GetOutputBuffer()
  {
    return csoundGetOutputBuffer(csound);
  }
  virtual MYFLT *GetSpin()
  {
    return csoundGetSpin(csound);
  }
  virtual MYFLT *GetSpout()
  {
    return csoundGetSpout(csound);
  }
  virtual const char *GetOutputFileName()
  {
    return csoundGetOutputFileName(csound);
  }
  virtual void SetHostImplementedAudioIO(int state, int bufSize)
  {
    csoundSetHostImplementedAudioIO(csound, state, bufSize);
  }
  virtual double GetScoreTime()
  {
    return csoundGetScoreTime(csound);
  }
  // score handling
  virtual int IsScorePending()
  {
    return csoundIsScorePending(csound);
  }
  virtual void SetScorePending(int pending)
  {
    csoundSetScorePending(csound, pending);
  }
  virtual MYFLT GetScoreOffsetSeconds()
  {
    return csoundGetScoreOffsetSeconds(csound);
  }
  virtual void SetScoreOffsetSeconds(double time)
  {
    csoundSetScoreOffsetSeconds(csound, (MYFLT) time);
  }
  virtual void RewindScore()
  {
    csoundRewindScore(csound);
  }
  virtual void SetCscoreCallback(void (*cscoreCallback_)(CSOUND *))
  {
    csoundSetCscoreCallback(csound, cscoreCallback_);
  }
  virtual int ScoreSort(FILE *inFile, FILE *outFile)
  {
    return csoundScoreSort(csound, inFile, outFile);
  }
  virtual int ScoreExtract(FILE *inFile, FILE *outFile, FILE *extractFile)
  {
    return csoundScoreExtract(csound, inFile, outFile, extractFile);
  }
  // messages & text
  virtual void Message(const char *format, ...)
  {
    va_list args;
    va_start(args, format);
    csoundMessageV(csound, 0, format, args);
    va_end(args);
  }
  virtual void MessageS(int attr, const char *format, ...)
  {
    va_list args;
    va_start(args, format);
    csoundMessageV(csound, attr, format, args);
    va_end(args);
  }
  virtual void MessageV(int attr, const char *format, va_list args)
  {
    csoundMessageV(csound, attr, format, args);
  }
  virtual void SetMessageCallback(
      void (*csoundMessageCallback_)(CSOUND *, int attr,
                                     const char *format, va_list valist))
  {
    csoundSetMessageCallback(csound, csoundMessageCallback_);
  }
  virtual int GetMessageLevel()
  {
    return csoundGetMessageLevel(csound);
  }
  virtual void SetMessageLevel(int messageLevel)
  {
    csoundSetMessageLevel(csound, messageLevel);
  }
  virtual void InputMessage(const char *message)
  {
    csoundInputMessage(csound, message);
  }
  virtual void KeyPressed(char c)
  {
    csoundKeyPress(csound, c);
  }
  // control and events
  virtual void SetInputValueCallback(
      void (*inputValueCallback_)(CSOUND *, const char *, MYFLT *))
  {
    csoundSetInputValueCallback(csound, inputValueCallback_);
  }
  virtual void SetOutputValueCallback(
      void (*outputValueCallback_)(CSOUND *, const char *, MYFLT))
  {
    csoundSetOutputValueCallback(csound, outputValueCallback_);
  }
  virtual int ScoreEvent(char type, const MYFLT *pFields, long numFields)
  {
    return csoundScoreEvent(csound, type, pFields, numFields);
  }
  virtual int ScoreEventAbsolute(char type, const MYFLT *pFields,
				 long numFields, double time_ofs)
  {
    return csoundScoreEventAbsolute(csound, type, pFields, numFields, time_ofs);
  }
  // MIDI
  virtual void SetExternalMidiInOpenCallback(
      int (*func)(CSOUND *, void **, const char *))
  {
    csoundSetExternalMidiInOpenCallback(csound, func);
  }
  virtual void SetExternalMidiReadCallback(
      int (*func)(CSOUND *, void *, unsigned char *, int))
  {
    csoundSetExternalMidiReadCallback(csound, func);
  }
  virtual void SetExternalMidiInCloseCallback(
      int (*func)(CSOUND *, void *))
  {
    csoundSetExternalMidiInCloseCallback(csound, func);
  }
  virtual void SetExternalMidiOutOpenCallback(
      int (*func)(CSOUND *, void **, const char *))
  {
    csoundSetExternalMidiOutOpenCallback(csound, func);
  }
  virtual void SetExternalMidiWriteCallback(
      int (*func)(CSOUND *, void *, const unsigned char *, int))
  {
    csoundSetExternalMidiWriteCallback(csound, func);
  }
  virtual void SetExternalMidiOutCloseCallback(
      int (*func)(CSOUND *, void *))
  {
    csoundSetExternalMidiOutCloseCallback(csound, func);
  }
  virtual void SetExternalMidiErrorStringCallback(
      const char *(*func)(int))
  {
    csoundSetExternalMidiErrorStringCallback(csound, func);
  }
  // function table display
  virtual int SetIsGraphable(int isGraphable)
  {
    return csoundSetIsGraphable(csound, isGraphable);
  }
  virtual void SetMakeGraphCallback(
      void (*makeGraphCallback_)(CSOUND *, WINDAT *windat, const char *name))
  {
    csoundSetMakeGraphCallback(csound, makeGraphCallback_);
  }
  virtual void SetDrawGraphCallback(
      void (*drawGraphCallback_)(CSOUND *, WINDAT *windat))
  {
    csoundSetDrawGraphCallback(csound, drawGraphCallback_);
  }
  virtual void SetKillGraphCallback(
      void (*killGraphCallback_)(CSOUND *, WINDAT *windat))
  {
    csoundSetKillGraphCallback(csound, killGraphCallback_);
  }
  virtual void SetMakeXYinCallback(
      void (*makeXYinCallback_)(CSOUND *, XYINDAT *, MYFLT x, MYFLT y))
  {
    csoundSetMakeXYinCallback(csound, makeXYinCallback_);
  }
  virtual void SetReadXYinCallback(
      void (*readXYinCallback_)(CSOUND *, XYINDAT *))
  {
    csoundSetReadXYinCallback(csound, readXYinCallback_);
  }
  virtual void SetKillXYinCallback(
      void (*killXYinCallback_)(CSOUND *, XYINDAT *))
  {
    csoundSetKillXYinCallback(csound, killXYinCallback_);
  }
  virtual void SetExitGraphCallback(
      int (*exitGraphCallback_)(CSOUND *))
  {
    csoundSetExitGraphCallback(csound, exitGraphCallback_);
  }
  // opcodes
  virtual int NewOpcodeList(opcodeListEntry* &opcodelist)
  {
    opcodeListEntry *tmp = (opcodeListEntry*) 0;
    int retval;
    retval = csoundNewOpcodeList(csound, &tmp);
    opcodelist = tmp;
    return retval;
  }
  virtual void DisposeOpcodeList(opcodeListEntry *opcodelist)
  {
    csoundDisposeOpcodeList(csound, opcodelist);
  }
  virtual int AppendOpcode(const char *opname, int dsblksiz, int thread,
                           const char *outypes, const char *intypes,
                           int (*iopadr)(CSOUND *, void *),
                           int (*kopadr)(CSOUND *, void *),
                           int (*aopadr)(CSOUND *, void *))
  {
    return csoundAppendOpcode(csound, opname, dsblksiz, thread,
                              outypes, intypes, iopadr, kopadr, aopadr);
  }
  // miscellaneous functions
  virtual void SetYieldCallback(int (*yieldCallback_)(CSOUND *))
  {
    csoundSetYieldCallback(csound, yieldCallback_);
  }
  // real-time audio play and record
  virtual void SetPlayopenCallback(
      int (*playopen__)(CSOUND *, const csRtAudioParams *parm))
  {
    csoundSetPlayopenCallback(csound, playopen__);
  }
  virtual void SetRtplayCallback(
      void (*rtplay__)(CSOUND *, const MYFLT *outBuf, int nbytes))
  {
    csoundSetRtplayCallback(csound, rtplay__);
  }
  virtual void SetRecopenCallback(
      int (*recopen_)(CSOUND *, const csRtAudioParams *parm))
  {
    csoundSetRecopenCallback(csound, recopen_);
  }
  virtual void SetRtrecordCallback(
      int (*rtrecord__)(CSOUND *, MYFLT *inBuf, int nbytes))
  {
    csoundSetRtrecordCallback(csound, rtrecord__);
  }
  virtual void SetRtcloseCallback(
      void (*rtclose__)(CSOUND *))
  {
    csoundSetRtcloseCallback(csound, rtclose__);
  }
  // --------
  virtual int GetDebug()
  {
    return csoundGetDebug(csound);
  }
  virtual void SetDebug(int debug)
  {
    csoundSetDebug(csound, debug);
  }
  virtual int TableLength(int table)
  {
    return csoundTableLength(csound, table);
  }
  virtual MYFLT TableGet(int table, int index)
  {
    return csoundTableGet(csound, table, index);
  }
  virtual void TableSet(int table, int index, double value)
  {
    csoundTableSet(csound, table, index, (MYFLT) value);
  }
  virtual int GetTable(MYFLT* &tablePtr, int tableNum)
  {
    MYFLT *ftable;
    int   tmp;
    tmp = csoundGetTable(csound, &ftable, tableNum);
    tablePtr = ftable;
    return tmp;
  }
  virtual int CreateGlobalVariable(const char *name, size_t nbytes)
  {
    return csoundCreateGlobalVariable(csound, name, nbytes);
  }
  virtual void *QueryGlobalVariable(const char *name)
  {
    return csoundQueryGlobalVariable(csound, name);
  }
  virtual void *QueryGlobalVariableNoCheck(const char *name)
  {
    return csoundQueryGlobalVariableNoCheck(csound, name);
  }
  virtual int DestroyGlobalVariable(const char *name)
  {
    return csoundDestroyGlobalVariable(csound, name);
  }
  virtual void **GetRtRecordUserData()
  {
    return csoundGetRtRecordUserData(csound);
  }
  virtual void **GetRtPlayUserData()
  {
    return csoundGetRtPlayUserData(csound);
  }
  virtual int RegisterSenseEventCallback(void (*func)(CSOUND *, void *),
                                         void *userData)
  {
    return csoundRegisterSenseEventCallback(csound, func, userData);
  }
  virtual int RunUtility(const char *name, int argc, char **argv)
  {
    return csoundRunUtility(csound, name, argc, argv);
  }
  virtual char **ListUtilities()
  {
    return csoundListUtilities(csound);
  }
  virtual void DeleteUtilityList(char **lst)
  {
    csoundDeleteUtilityList(csound, lst);
  }
  virtual const char *GetUtilityDescription(const char *utilName)
  {
    return csoundGetUtilityDescription(csound, utilName);
  }
  virtual int GetChannelPtr(MYFLT* &p, const char *name, int type)
  {
    MYFLT *tmp;
    int   retval;
    retval = csoundGetChannelPtr(csound, &tmp, name, type);
    p = tmp;
    return retval;
  }
  virtual int ListChannels(CsoundChannelListEntry* &lst)
  {
    CsoundChannelListEntry  *tmp;
    int                     retval;
    retval = csoundListChannels(csound, &tmp);
    lst = tmp;
    return retval;
  }
  virtual void DeleteChannelList(CsoundChannelListEntry *lst)
  {
    csoundDeleteChannelList(csound, lst);
  }
  virtual int SetControlChannelParams(const char *name, int type,
                                      double dflt, double min, double max)
  {
    return csoundSetControlChannelParams(csound, name, type, (MYFLT) dflt,
                                         (MYFLT) min, (MYFLT) max);
  }
  virtual int GetControlChannelParams(const char *name,
                                      MYFLT &dflt, MYFLT &min, MYFLT &max)
  {
    MYFLT tmp1 = (MYFLT) 0, tmp2 = (MYFLT) 0, tmp3 = (MYFLT) 0;
    int   retval;
    retval = csoundGetControlChannelParams(csound, name, &tmp1, &tmp2, &tmp3);
    dflt = tmp1;
    min = tmp2;
    max = tmp3;
    return retval;
  }
  virtual void SetChannel(const char *name, double value)
  {
    MYFLT *p;
    if (!(csoundGetChannelPtr(csound, &p, name,
                              CSOUND_CONTROL_CHANNEL | CSOUND_INPUT_CHANNEL)))
      *p = (MYFLT) value;
  }
  virtual void SetChannel(const char *name, const char *value)
  {
    MYFLT *p;
    if (!(csoundGetChannelPtr(csound, &p, name,
                              CSOUND_STRING_CHANNEL | CSOUND_INPUT_CHANNEL))) {
      size_t maxLen = (size_t) (csoundGetStrVarMaxLen(csound) - 1);
      size_t i = (size_t) 0;
      while (value[i]) {
        ((char*) p)[i] = value[i];
        if (++i >= maxLen)
          break;
      }
      ((char*) p)[i] = '\0';
    }
  }
  virtual MYFLT GetChannel(const char *name)
  {
    MYFLT *p;
    if (!(csoundGetChannelPtr(csound, &p, name,
                              CSOUND_CONTROL_CHANNEL | CSOUND_OUTPUT_CHANNEL)))
      return (*p);
    return (MYFLT) 0;
  }
  virtual int ChanIKSet(double value, int n)
  {
    return csoundChanIKSet(csound, (MYFLT) value, n);
  }
  virtual int ChanOKGet(MYFLT &value, int n)
  {
    MYFLT tmp = (MYFLT) 0;
    int   retval;
    retval = csoundChanOKGet(csound, &tmp, n);
    value = tmp;
    return retval;
  }
  virtual int ChanIASet(const MYFLT *value, int n)
  {
    return csoundChanIASet(csound, value, n);
  }
  virtual int ChanOAGet(MYFLT *value, int n)
  {
    return csoundChanOAGet(csound, value, n);
  }


  virtual int PvsinSet(const PVSDATEXT* value, int n)
  {
    return csoundPvsinSet(csound, value, n);
  }

  virtual int PvsoutGet(PVSDATEXT* value, int n)
  {
    return csoundPvsoutGet(csound, value, n);
  }

  // cfgvar.h interface
  virtual int CreateConfigurationVariable(const char *name, void *p,
                                          int type, int flags,
                                          void *min, void *max,
                                          const char *shortDesc,
                                          const char *longDesc)
  {
    return csoundCreateConfigurationVariable(csound, name, p, type, flags,
                                             min, max, shortDesc, longDesc);
  }
#if 0
  virtual int CopyGlobalConfigurationVariable(const char *name, void *p)
  {
    return csoundCopyGlobalConfigurationVariable(csound, name, p);
  }
  virtual int CopyGlobalConfigurationVariables()
  {
    return csoundCopyGlobalConfigurationVariables(csound);
  }
#endif
  virtual int SetConfigurationVariable(const char *name, void *value)
  {
    return csoundSetConfigurationVariable(csound, name, value);
  }
  virtual int ParseConfigurationVariable(const char *name, const char *value)
  {
    return csoundParseConfigurationVariable(csound, name, value);
  }
  virtual csCfgVariable_t *QueryConfigurationVariable(const char *name)
  {
    return csoundQueryConfigurationVariable(csound, name);
  }
  virtual csCfgVariable_t **ListConfigurationVariables()
  {
    return csoundListConfigurationVariables(csound);
  }
  virtual int DeleteConfigurationVariable(const char *name)
  {
    return csoundDeleteConfigurationVariable(csound, name);
  }
  virtual void SetChannelIOCallback(CsoundChannelIOCallback_t func)
  {
    csoundSetChannelIOCallback(csound, func);
  }
  // constructors
  // FIXME: should throw exception on failure ?
  Csound()
  {
    csound = csoundCreate((CSOUND*) 0);
     #ifdef SWIGPYTHON
      pydata =(pycbdata *) new pycbdata;
      memset(pydata, sizeof(pydata), 0);
    ((pycbdata *)pydata)->mfunc = NULL;
    ((pycbdata *)pydata)->messageBufferIndex = 0;
    csoundSetHostData(csound, this);
    #endif
  }
  Csound(void *hostData)
  {
    csound = csoundCreate(hostData);
    #ifdef SWIGPYTHON
    pydata =(pycbdata *) new pycbdata;
    ((pycbdata *)pydata)->mfunc = NULL;
    ((pycbdata *)pydata)->messageBufferIndex = 0;
    csoundSetHostData(csound, this);
    #endif
  }
  // destructor
  virtual ~Csound()
  {
    csoundDestroy(csound);
    #ifdef SWIGPYTHON
    ((pycbdata *)pydata)->mfunc = NULL;
    delete (pycbdata *)pydata;
    #endif

  }
  // Functions for embedding.
  virtual void EnableMessageBuffer(int toStdOut)
  {
    csoundEnableMessageBuffer(csound, toStdOut);
  }
  virtual const char *GetFirstMessage()
  {
    return csoundGetFirstMessage(csound);
  }
  virtual int GetFirstMessageAttr()
  {
    return csoundGetFirstMessageAttr(csound);
  }
  virtual void PopFirstMessage()
  {
    csoundPopFirstMessage(csound);
  }
  virtual int GetMessageCnt()
  {
    return csoundGetMessageCnt(csound);
  }
  virtual void DestroyMessageBuffer()
  {
    csoundDestroyMessageBuffer(csound);
  }
  virtual void AddSpinSample(int frame, int channel, MYFLT sample)
  {
    csoundAddSpinSample(csound, frame, channel, sample);
  }
  virtual MYFLT GetSpoutSample(int frame, int channel) const
  {
    return csoundGetSpoutSample(csound, frame, channel);
  }
  virtual int ChanIKSetValue(int channel, MYFLT value)
  {
    return csoundChanIKSetValue(csound, channel, value);
  }
  virtual MYFLT ChanOKGetValue(int channel)
  {
    return  csoundChanOKGetValue(csound, channel);
  }
  virtual int ChanIASetSample(int channel, int frame, MYFLT sample)
  {
    return csoundChanIASetSample(csound, channel, frame, sample);
  }
  virtual MYFLT ChanOAGetSample(int channel, int frame)
  {
    return csoundChanOAGetSample(csound, channel, frame);
  }
};

// thread locks

class CsoundThreadLock {
protected:
  void  *threadLock;
public:
  int Lock(size_t milliseconds)
  {
    return csoundWaitThreadLock(threadLock, milliseconds);
  }
  void Lock()
  {
    csoundWaitThreadLockNoTimeout(threadLock);
  }
  int TryLock()
  {
    return csoundWaitThreadLock(threadLock, (size_t) 0);
  }
  void Unlock()
  {
    csoundNotifyThreadLock(threadLock);
  }
  // constructors
  // FIXME: should throw exception on failure ?
  CsoundThreadLock()
  {
    threadLock = csoundCreateThreadLock();
  }
  CsoundThreadLock(int locked)
  {
    threadLock = csoundCreateThreadLock();
    if (locked)
      csoundWaitThreadLock(threadLock, (size_t) 0);
  }
  // destructor
  ~CsoundThreadLock()
  {
    csoundDestroyThreadLock(threadLock);
  }
};

class CsoundMutex {
protected:
  void  *mutex_;
public:
  void Lock()
  {
    csoundLockMutex(mutex_);
  }
  // FIXME: this may be unimplemented on Windows
  int TryLock()
  {
    return csoundLockMutexNoWait(mutex_);
  }
  void Unlock()
  {
    csoundUnlockMutex(mutex_);
  }
  // constructors
  // FIXME: should throw exception on failure ?
  CsoundMutex()
  {
    mutex_ = csoundCreateMutex(1);
  }
  CsoundMutex(int isRecursive)
  {
    mutex_ = csoundCreateMutex(isRecursive);
  }
  // destructor
  ~CsoundMutex()
  {
    csoundDestroyMutex(mutex_);
  }
};

// Mersenne Twister (MT19937) pseudo-random number generator

class CsoundRandMT {
protected:
  CsoundRandMTState   mt;
public:
  uint32_t Random()
  {
    return csoundRandMT(&mt);
  }
  void Seed(uint32_t seedVal)
  {
    csoundSeedRandMT(&mt, (uint32_t*) 0, seedVal);
  }
  void Seed(const uint32_t *initKey, int keyLength)
  {
    csoundSeedRandMT(&mt, initKey, (uint32_t) keyLength);
  }
  // constructors
  CsoundRandMT()
  {
    csoundSeedRandMT(&mt, (uint32_t*) 0, csoundGetRandomSeedFromTime());
  }
  CsoundRandMT(uint32_t seedVal)
  {
    csoundSeedRandMT(&mt, (uint32_t*) 0, seedVal);
  }
  CsoundRandMT(const uint32_t *initKey, int keyLength)
  {
    csoundSeedRandMT(&mt, initKey, (uint32_t) keyLength);
  }
  ~CsoundRandMT()
  {
  }
};

// timer (csoundInitialize() should be called before using this)

class CsoundTimer {
protected:
  RTCLOCK rt;
public:
  double GetRealTime()
  {
    return csoundGetRealTime(&rt);
  }
  double GetCPUTime()
  {
    return csoundGetCPUTime(&rt);
  }
  void Reset()
  {
    csoundInitTimerStruct(&rt);
  }
  // constructor
  CsoundTimer()
  {
    csoundInitTimerStruct(&rt);
  }
  ~CsoundTimer()
  {
  }
};

#endif  // __cplusplus

#endif  // __CSOUND_HPP__

