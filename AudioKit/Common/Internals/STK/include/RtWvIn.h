#ifndef STK_RTWVIN_H
#define STK_RTWVIN_H

#include "WvIn.h"
#include "RtAudio.h"
#include "Mutex.h"

namespace stk {

/***************************************************/
/*! \class RtWvIn
    \brief STK realtime audio (blocking) input class.

    This class provides a simplified interface to RtAudio for realtime
    audio input.  It is a subclass of WvIn.  This class makes use of
    RtAudio's callback functionality by creating a large ring-buffer
    from which data is read.  This class should not be used when
    low-latency is desired.

    RtWvIn supports multi-channel data in both interleaved and
    non-interleaved formats.  It is important to distinguish the
    tick() method that computes a single frame (and returns only the
    specified sample of a multi-channel frame) from the overloaded one
    that takes an StkFrames object for multi-channel and/or
    multi-frame data.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class RtWvIn : public WvIn
{
public:
  //! Default constructor.
  /*!
    The default \e device argument value (zero) will select the
    default input device on your system.  The first device enumerated
    by the underlying audio API is specified with a value of one.  The
    default buffer size of RT_BUFFER_SIZE is defined in Stk.h.  An
    StkError will be thrown if an error occurs duing instantiation.
  */
  RtWvIn( unsigned int nChannels = 1, StkFloat sampleRate = Stk::sampleRate(),
          int device = 0, int bufferFrames = RT_BUFFER_SIZE, int nBuffers = 20 );

  //! Class destructor.
  ~RtWvIn();

  //! Start the audio input stream.
  /*!
    The stream is started automatically, if necessary, when a
    tick() or tickFrame() method is called.
  */
  void start( void );

  //! Stop the audio input stream.
  /*!
    It may be necessary to use this method to avoid audio underflow
    problems if you wish to temporarily stop audio input.
  */
  void stop( void );

  //! Return the specified channel value of the last computed frame.
  /*!
    For multi-channel files, use the lastFrame() function to get
    all values from the last computed frame.  If the device is
    stopped, the returned value is 0.0.  The \c channel argument must
    be less than the number of channels in the audio stream (the first
    channel is specified by 0).  However, range checking is only
    performed if _STK_DEBUG_ is defined during compilation, in which
    case an out-of-range value will trigger an StkError exception.
  */
  StkFloat lastOut( unsigned int channel = 0 );

  //! Compute a sample frame and return the specified \c channel value.
  /*!
    For multi-channel files, use the lastFrame() function to get
    all values from the computed frame.  If the device is "stopped",
    it is "started".  The \c channel argument must be less than the
    number of channels in the audio stream (the first channel is
    specified by 0).  However, range checking is only performed if
    _STK_DEBUG_ is defined during compilation, in which case an
    out-of-range value will trigger an StkError exception.
  */
  StkFloat tick( unsigned int channel = 0 );

  //! Fill the StkFrames object with computed sample frames, starting at the specified channel and return the same reference.
  /*!
    If the device is "stopped", it is "started".  The \c channel
    argument plus the number of input channels must be less than the
    number of channels in the StkFrames argument (the first channel is
    specified by 0).  However, range checking is only performed if
    _STK_DEBUG_ is defined during compilation, in which case an
    out-of-range value will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  // This function is not intended for general use but must be
  // public for access from the audio callback function.
  void fillBuffer( void *buffer, unsigned int nFrames );

protected:

	RtAudio adc_;
  Mutex mutex_;
  bool stopped_;
  unsigned int readIndex_;
  unsigned int writeIndex_;
  unsigned int framesFilled_;

};

inline StkFloat RtWvIn :: lastOut( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= data_.channels() ) {
    oStream_ << "RtWvIn::lastOut(): channel argument and audio stream are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  return lastFrame_[channel];
}

} // stk namespace

#endif
