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
   * For sample accurate timing, kperf may be called at some
   * offset after the first frame of the kperiod. Hence, opcodes
   * must output zeros up until the offset, and then output
   * their signal until the end of the kperiod. After the first
   * kperiod of activation, the offset will always be 0.
   */
  uint32_t kperiodOffset() const
  {
      return opds.insdshead->ksmps_offset;
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
   * For sample accurate timing, kperf may be called at some
   * offset after the first frame of the kperiod. Hence, opcodes
   * must output zeros up until the offset, and then output
   * their signal until the end of the kperiod. After the first
   * kperiod of activation, the offset will always be 0.
   */
  uint32_t kperiodOffset() const
  {
      return opds.insdshead->ksmps_offset;
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
