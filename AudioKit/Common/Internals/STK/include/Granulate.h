#ifndef STK_GRANULATE_H
#define STK_GRANULATE_H

#include <vector>
#include "Generator.h"
#include "Envelope.h"
#include "Noise.h"

namespace stk {

/***************************************************/
/*! \class Granulate
    \brief STK granular synthesis class.

    This class implements a real-time granular synthesis algorithm
    that operates on an input soundfile.  Multi-channel files are
    supported.  Various functions are provided to allow control over
    voice and grain parameters.

    The functionality of this class is based on the program MacPod by
    Chris Rolfe and Damian Keller, though there are likely to be a
    number of differences in the actual implementation.

    by Gary Scavone, 2005 - 2010.
*/
/***************************************************/

class Granulate: public Generator
{
 public:
  //! Default constructor.
  Granulate( void );

  //! Constructor taking input audio file and number of voices arguments.
  Granulate( unsigned int nVoices, std::string fileName, bool typeRaw = false );

  //! Class destructor.
  ~Granulate( void );

  //! Load a monophonic soundfile to be "granulated".
  /*!
    An StkError will be thrown if the file is not found, its format
    is unknown or unsupported, or the file has more than one channel.
  */
  void openFile( std::string fileName, bool typeRaw = false );

  //! Reset the file pointer and all existing grains to the file start.
  /*!
    Multiple grains are offset from one another in time by grain
    duration / nVoices.
  */
  void reset( void );

  //! Set the number of simultaneous grain "voices" to use.
  /*!
    Multiple grains are offset from one another in time by grain
    duration / nVoices.  For this reason, it is best to set the grain
    parameters before calling this function (during initialization).
  */
  void setVoices( unsigned int nVoices = 1 );

  //! Set the stretch factor used for grain playback (1 - 1000).
  /*!
    Granular synthesis allows for time-stetching without affecting
    the original pitch of a sound.  A stretch factor of 4 will produce
    a resulting sound of length 4 times the orignal sound.  The
    default parameter of 1 produces no stretching.
  */
  void setStretch( unsigned int stretchFactor = 1 );

  //! Set global grain parameters used to determine individual grain settings.
  /*!
    Each grain is defined as having a length of \e duration
    milliseconds which must be greater than zero.  For values of \e
    rampPercent (0 - 100) greater than zero, a linear envelope will be
    applied to each grain.  If \e rampPercent = 100, the resultant
    grain "window" is triangular while \e rampPercent = 50 produces a
    trapezoidal window.  In addition, each grain can have a time delay
    of length \e delay and a grain pointer increment of length \e
    offset, which can be negative, before the next ramp onset (in
    milliseconds).  The \e offset parameter controls grain pointer
    jumps between enveloped grain segments, while the \e delay
    parameter causes grain calculations to pause between grains.  The
    actual values calculated for each grain will be randomized by a
    factor set using the setRandomFactor() function.
  */
  void setGrainParameters( unsigned int duration = 30, unsigned int rampPercent = 50,
                           int offset = 0, unsigned int delay = 0 );

  //! This factor is used when setting individual grain parameters (0.0 - 1.0).
  /*!
    This random factor is applied when all grain state durations
    are calculated.  If set to 0.0, no randomness occurs.  When
    randomness = 1.0, a grain segment of length \e duration will be
    randomly augmented by up to +- \e duration seconds (i.e., a 30
    millisecond length will be augmented by an extra length of up to
    +30 or -30 milliseconds).
   */
  void setRandomFactor( StkFloat randomness = 0.1 );

  //! Return the specified channel value of the last computed frame.
  /*!
    The \c channel argument must be less than the number of output
    channels, which can be determined with the channelsOut() function
    (the first channel is specified by 0).  However, range checking is
    only performed if _STK_DEBUG_ is defined during compilation, in
    which case an out-of-range value will trigger an StkError
    exception. \sa lastFrame()
  */
  StkFloat lastOut( unsigned int channel = 0 );

  //! Compute one sample frame and return the specified \c channel value.
  StkFloat tick( unsigned int channel = 0 );

  //! Fill the StkFrames object with computed sample frames, starting at the specified channel.
  /*!
    The \c channel argument plus the number of output channels must
    be less than the number of channels in the StkFrames argument (the
    first channel is specified by 0).  However, range checking is only
    performed if _STK_DEBUG_ is defined during compilation, in which
    case an out-of-range value will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  enum GrainState {
    GRAIN_STOPPED,
    GRAIN_FADEIN,
    GRAIN_SUSTAIN,
    GRAIN_FADEOUT
  };

 protected:

  struct Grain {
    StkFloat eScaler;
    StkFloat eRate;
    unsigned long attackCount;
    unsigned long sustainCount;
    unsigned long decayCount;
    unsigned long delayCount;
    unsigned long counter;
    //unsigned long pointer;
    StkFloat pointer;
    unsigned long startPointer;
    unsigned int repeats;
    GrainState state;

    // Default constructor.
    Grain()
      :eScaler(0.0), eRate(0.0), attackCount(0), sustainCount(0), decayCount(0),
       delayCount(0), counter(0), pointer(0), startPointer(0), repeats(0), state(GRAIN_STOPPED) {}
  };

  void calculateGrain( Granulate::Grain& grain );

  StkFrames data_;
  std::vector<Grain> grains_;
  Noise noise;
  //long gPointer_;
  StkFloat gPointer_;

  // Global grain parameters.
  unsigned int gDuration_;
  unsigned int gRampPercent_;
  unsigned int gDelay_;
  unsigned int gStretch_;
  unsigned int stretchCounter_;
  int gOffset_;
  StkFloat gRandomFactor_;
  StkFloat gain_;

};

inline StkFloat Granulate :: lastOut( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= lastFrame_.channels() ) {
    oStream_ << "Granulate::lastOut(): channel argument is invalid!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  return lastFrame_[channel];
}

inline StkFrames& Granulate :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Granulate::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - nChannels;
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    *samples++ = tick();
    for ( j=1; j<nChannels; j++ )
      *samples++ = lastFrame_[j];
  }

  return frames;
}

} // stk namespace

#endif
