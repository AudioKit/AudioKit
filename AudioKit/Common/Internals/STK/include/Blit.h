#ifndef STK_BLIT_H
#define STK_BLIT_H

#include "Generator.h"
#include <cmath>
#include <limits>

namespace stk {

/***************************************************/
/*! \class Blit
    \brief STK band-limited impulse train class.

    This class generates a band-limited impulse train using a
    closed-form algorithm reported by Stilson and Smith in "Alias-Free
    Digital Synthesis of Classic Analog Waveforms", 1996.  The user
    can specify both the fundamental frequency of the impulse train
    and the number of harmonics contained in the resulting signal.

    The signal is normalized so that the peak value is +/-1.0.

    If nHarmonics is 0, then the signal will contain all harmonics up
    to half the sample rate.  Note, however, that this setting may
    produce aliasing in the signal when the frequency is changing (no
    automatic modification of the number of harmonics is performed by
    the setFrequency() function).

    Original code by Robin Davies, 2005.
    Revisions by Gary Scavone for STK, 2005.
*/
/***************************************************/

class Blit: public Generator
{
 public:
  //! Default constructor that initializes BLIT frequency to 220 Hz.
  Blit( StkFloat frequency = 220.0 );

  //! Class destructor.
  ~Blit();

  //! Resets the oscillator state and phase to 0.
  void reset();

  //! Set the phase of the signal.
  /*!
    Set the phase of the signal, in the range 0 to 1.
  */
  void setPhase( StkFloat phase ) { phase_ = PI * phase; };

  //! Get the current phase of the signal.
  /*!
    Get the phase of the signal, in the range [0 to 1.0).
  */
  StkFloat getPhase() const { return phase_ / PI; };

  //! Set the impulse train rate in terms of a frequency in Hz.
  void setFrequency( StkFloat frequency );

  //! Set the number of harmonics generated in the signal.
  /*!
    This function sets the number of harmonics contained in the
    resulting signal.  It is equivalent to (2 * M) + 1 in the BLIT
    algorithm.  The default value of 0 sets the algorithm for maximum
    harmonic content (harmonics up to half the sample rate).  This
    parameter is not checked against the current sample rate and
    fundamental frequency.  Thus, aliasing can result if one or more
    harmonics for a given fundamental frequency exceeds fs / 2.  This
    behavior was chosen over the potentially more problematic solution
    of automatically modifying the M parameter, which can produce
    audible clicks in the signal.
  */
  void setHarmonics( unsigned int nHarmonics = 0 );

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Compute and return one output sample.
  StkFloat tick( void );

  //! Fill a channel of the StkFrames object with computed outputs.
  /*!
    The \c channel argument must be less than the number of
    channels in the StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

 protected:

  void updateHarmonics( void );

  unsigned int nHarmonics_;
  unsigned int m_;
  StkFloat rate_;
  StkFloat phase_;
  StkFloat p_;

};

inline StkFloat Blit :: tick( void )
{
  // The code below implements the SincM algorithm of Stilson and
  // Smith with an additional scale factor of P / M applied to
  // normalize the output.

  // A fully optimized version of this code would replace the two sin
  // calls with a pair of fast sin oscillators, for which stable fast
  // two-multiply algorithms are well known. In the spirit of STK,
  // which favors clarity over performance, the optimization has not
  // been made here.

  // Avoid a divide by zero at the sinc peak, which has a limiting
  // value of 1.0.
  StkFloat tmp, denominator = sin( phase_ );
  if ( denominator <= std::numeric_limits<StkFloat>::epsilon() )
    tmp = 1.0;
  else {
    tmp =  sin( m_ * phase_ );
    tmp /= m_ * denominator;
  }

  phase_ += rate_;
  if ( phase_ >= PI ) phase_ -= PI;

  lastFrame_[0] = tmp;
	return lastFrame_[0];
}

inline StkFrames& Blit :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Blit::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = Blit::tick();

  return frames;
}

} // stk namespace

#endif
