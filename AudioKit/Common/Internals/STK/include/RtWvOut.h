#ifndef STK_RTWVOUT_H
#define STK_RTWVOUT_H

#include "WvOut.h"
#include "RtAudio.h"
#include "Mutex.h"

namespace stk {

/***************************************************/
/*! \class RtWvOut
    \brief STK realtime audio (blocking) output class.

    This class provides a simplified interface to RtAudio for realtime
    audio output.  It is a subclass of WvOut.  This class makes use of
    RtAudio's callback functionality by creating a large ring-buffer
    into which data is written.  This class should not be used when
    low-latency is desired.

    RtWvOut supports multi-channel data in interleaved format.  It is
    important to distinguish the tick() method that outputs a single
    sample to all channels in a sample frame from the overloaded one
    that takes a reference to an StkFrames object for multi-channel
    and/or multi-frame data.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class RtWvOut : public WvOut
{
 public:

  //! Default constructor.
  /*!
    The default \e device argument value (zero) will select the
    default output device on your system.  The first device enumerated
    by the underlying audio API is specified with a value of one.  The
    default buffer size of RT_BUFFER_SIZE is defined in Stk.h.  An
    StkError will be thrown if an error occurs duing instantiation.
  */
  RtWvOut( unsigned int nChannels = 1, StkFloat sampleRate = Stk::sampleRate(),
           int device = 0, int bufferFrames = RT_BUFFER_SIZE, int nBuffers = 20 );

  //! Class destructor.
  ~RtWvOut();

  //! Start the audio output stream.
  /*!
    The stream is started automatically, if necessary, when a
    tick() method is called.
  */
  void start( void );

  //! Stop the audio output stream.
  /*!
    It may be necessary to use this method to avoid undesireable
    audio buffer cycling if you wish to temporarily stop audio output.
  */
  void stop( void );

  //! Output a single sample to all channels in a sample frame.
  /*!
    If the device is "stopped", it is "started".
  */
  void tick( const StkFloat sample );

  //! Output the StkFrames data.
  /*!
    If the device is "stopped", it is "started".  The number of
    channels in the StkFrames argument must equal the number of
    channels specified during instantiation.  However, this is only
    checked if _STK_DEBUG_ is defined during compilation, in which
    case an incompatibility will trigger an StkError exception.
  */
  void tick( const StkFrames& frames );

  // This function is not intended for general use but must be
  // public for access from the audio callback function.
  int readBuffer( void *buffer, unsigned int frameCount );

 protected:

  RtAudio dac_;
  Mutex mutex_;
  bool stopped_;
  unsigned int readIndex_;
  unsigned int writeIndex_;
  long framesFilled_;
  unsigned int status_; // running = 0, emptying buffer = 1, finished = 2

};

} // stk namespace

#endif
