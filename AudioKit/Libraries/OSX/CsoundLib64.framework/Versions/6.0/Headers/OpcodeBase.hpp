#ifndef OPCODE_BASE_H
#define OPCODE_BASE_H


#include <interlocks.h>
#include <csdl.h>
#include <cstdarg>

/**
 * Template base class, or pseudo-virtual base class,
 * for writing Csound opcodes in C++.
 * Derive opcode implementation classes like this:
 *
 * DerivedClass : public OpcodeBase<DerivedClass>
 * {
 * public:
 *     // All output fields must be declared first as MYFLT *:
 *     MYFLT *aret1;
 *     // All input fields must be declared next as MYFLT *:
 *     MYFLT *iarg1;
 *     MYFLT *karg2;
 *     MYFLT *aarg3;
 *     // All internal state variables must be declared after that:
 *     size_t state1;
 *     double state2;
 *     MYFLT state3;
 *     // Declare and implement only whichever of these are required:
 *     int init();
 *     int kontrol();
 *     int audio;
 *     int noteoff();
 *     void deinit();
 * };
 */
template<typename T>
class OpcodeBase
{
public:
  int init(CSOUND *csound)
  {
    return NOTOK;
  }
  static int init_(CSOUND *csound, void *opcode)
  {
    return reinterpret_cast<T *>(opcode)->init(csound);
  }
  int kontrol(CSOUND *csound)
  {
    return NOTOK;
  }
  static int kontrol_(CSOUND *csound, void *opcode)
  {
    return reinterpret_cast<T *>(opcode)->kontrol(csound);
  }
  int audio(CSOUND *csound)
  {
    return NOTOK;
  }
  static int audio_(CSOUND *csound, void *opcode)
  {
    return reinterpret_cast<T *>(opcode)->audio(csound);
  }
  /**
    This is how to compute audio signals for normal opcodes:
    (1) Zero all frames from 0 up to but not including Offset.
    (2) Compute all frames from ksmps_offset up to but not including End.
    (3) Zero all frames from End up to but not including ksmps.
    Example from a C opcode:
    uint32_t offset = p->h.insdshead->ksmps_offset;
    uint32_t early  = p->h.insdshead->ksmps_no_end;
    uint32_t n, nsmps = CS_KSMPS;
    if (UNLIKELY(offset)) memset(p->r, '\0', offset*sizeof(MYFLT));
    if (UNLIKELY(early)) {
      nsmps -= early;
      memset(&p->r[nsmps], '\0', early*sizeof(MYFLT));
    }
    for (n = offset; n < nsmps; n++) {
      input1 = MYFLT2LRND(p->a[n]);
      p->r[n] = (MYFLT) (input1 >> input2);
    }
    So in C++ it should look like this (which is much easier to understand):
    int frameIndex = 0;
    for( ; frameIndex < kperiodOffset(); ++frameIndex) {
        asignal[frameIndex] = 0;
    }
    for( ; frameIndex < kperiodEnd(); ++frameIndex) {
        asignal[frameIndex] = compute();
    }
    for( ; frameIndex < ksmps(); ++frameIndex) {
        asignal[frameIndex] = 0;
    }
   */
  uint32_t kperiodOffset() const
  {
      return opds.insdshead->ksmps_offset;
  }
  uint32_t kperiodEnd() const
  {
      uint32_t end = opds.insdshead->ksmps_no_end;
      if (end) {
          return end;
      } else {
          return ksmps();
      }
  }
  uint32_t ksmps() const
  {
      return opds.insdshead->ksmps;
  }
  void log(CSOUND *csound, const char *format,...)
  {
    va_list args;
    va_start(args, format);
    if(csound) {
      csound->MessageV(csound, 0, format, args);
    }
    else {
      vfprintf(stdout, format, args);
    }
    va_end(args);
  }
  void warn(CSOUND *csound, const char *format,...)
  {
    if(csound) {
      if(csound->GetMessageLevel(csound) & WARNMSG) {
        va_list args;
        va_start(args, format);
        csound->MessageV(csound, CSOUNDMSG_WARNING, format, args);
        va_end(args);
      }
    }
    else {
      va_list args;
      va_start(args, format);
      vfprintf(stdout, format, args);
      va_end(args);
    }
  }
  OPDS opds;
};

template<typename T>
class OpcodeNoteoffBase
{
public:
  int init(CSOUND *csound)
  {
    return NOTOK;
  }
  static int init_(CSOUND *csound, void *opcode)
  {
    if (!csound->GetReinitFlag(csound) && !csound->GetTieFlag(csound)) {
      csound->RegisterDeinitCallback(csound, opcode,
                                     &OpcodeNoteoffBase<T>::noteoff_);
    }
    return reinterpret_cast<T *>(opcode)->init(csound);
  }
  int kontrol(CSOUND *csound)
  {
    return NOTOK;
  }
  static int kontrol_(CSOUND *csound, void *opcode)
  {
    return reinterpret_cast<T *>(opcode)->kontrol(csound);
  }
  int audio(CSOUND *csound)
  {
    return NOTOK;
  }
  static int audio_(CSOUND *csound, void *opcode)
  {
    return reinterpret_cast<T *>(opcode)->audio(csound);
  }
  /**
    This is how to compute audio signals for normal opcodes:
    (1) Zero all frames from 0 up to but not including Offset.
    (2) Compute all frames from ksmps_offset up to but not including End.
    (3) Zero all frames from End up to but not including ksmps.
    Example from a C opcode:
    uint32_t offset = p->h.insdshead->ksmps_offset;
    uint32_t early  = p->h.insdshead->ksmps_no_end;
    uint32_t n, nsmps = CS_KSMPS;
    if (UNLIKELY(offset)) memset(p->r, '\0', offset*sizeof(MYFLT));
    if (UNLIKELY(early)) {
      nsmps -= early;
      memset(&p->r[nsmps], '\0', early*sizeof(MYFLT));
    }
    for (n = offset; n < nsmps; n++) {
      input1 = MYFLT2LRND(p->a[n]);
      p->r[n] = (MYFLT) (input1 >> input2);
    }
    So in C++ it should look like this (which is much easier to understand):
    int frameIndex = 0;
    for( ; frameIndex < kperiodOffset(); ++frameIndex) {
        asignal[frameIndex] = 0;
    }
    for( ; frameIndex < kperiodEnd(); ++frameIndex) {
        asignal[frameIndex] = compute();
    }
    for( ; frameIndex < ksmps(); ++frameIndex) {
        asignal[frameIndex] = 0;
    }
   */
  uint32_t kperiodOffset() const
  {
      return opds.insdshead->ksmps_offset;
  }
  uint32_t kperiodEnd() const
  {
      uint32_t end = opds.insdshead->ksmps_no_end;
      if (end) {
          return end;
      } else {
          return ksmps();
      }
  }
  uint32_t ksmps() const
  {
      return opds.insdshead->ksmps;
  }
  void log(CSOUND *csound, const char *format,...)
  {
    va_list args;
    va_start(args, format);
    if(csound) {
      csound->MessageV(csound, 0, format, args);
    }
    else {
      vfprintf(stdout, format, args);
    }
    va_end(args);
  }
  void warn(CSOUND *csound, const char *format,...)
  {
    if(csound) {
      if(csound->GetMessageLevel(csound) & WARNMSG) {
        va_list args;
        va_start(args, format);
        csound->MessageV(csound, CSOUNDMSG_WARNING, format, args);
        va_end(args);
      }
    }
    else {
      va_list args;
      va_start(args, format);
      vfprintf(stdout, format, args);
      va_end(args);
    }
  }
  int noteoff(CSOUND *csound)
  {
    return OK;
  }
  static int noteoff_(CSOUND *csound, void *opcode)
  {
    return reinterpret_cast<T *>(opcode)->noteoff(csound);
  }
  OPDS opds;
};

#endif
