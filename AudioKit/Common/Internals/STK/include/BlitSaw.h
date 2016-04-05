#ifndef STK_BLITSAW_H
#define STK_BLITSAW_H

#include "Generator.h"
#include <cmath>
#include <limits>

namespace stk {

/***************************************************/
/*! \class BlitSaw
    \brief STK band-limited sawtooth wave class.

    This class generates a band-limited sawtooth waveform using a
    closed-form algorithm reported by Stilson and Smith in "Alias-Free
    Digital Synthesis of Classic Analog Waveforms", 1996.  The user
    can specify both the fundamental frequency of the sawtooth and the
    number of harmonics contained in the resulting signal.

    If nHarmonics is 0, then the signal will contain all harmonics up
    to half the sample rate.  Note, however, that this setting may
    produce aliasing in the signal when the frequency is changing (no
    automatic modification of the number of harmonics is performed by
    the setFrequency() function).

    Based on initial code of Robin Davies, 2005.
    Modified algorithm code by Gary Scavone, 2005.
*/
/***************************************************/

class BlitSaw: public Generator
{
 public:
  //! Class constructor.
  BlitSaw( StkFloat frequency = 220.0 );

  //! Class destructor.
  ~BlitSaw();

  //! Resets the oscillator state and phase to 0.
  void reset();

  //! Set the sawtooth oscillator rate in terms of a frequency in Hz.
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
  StkFloat C2_;
  StkFloat a_;
  StkFloat state_;

};

inline StkFloat BlitSaw :: tick( void )
{
  // The code below implements the BLIT algorithm of Stilson and
  // Smith, followed by a summation and filtering operation to produce
  // a sawtooth waveform.  After experimenting with various approaches
  // to calculate the average value of the BLIT over one period, I
  // found that an estimate of C2_ = 1.0 / period (in samples) worked
  // most consistently.  A "leaky integrator" is then applied to the
  // difference of the BLIT output and C2_. (GPS - 1 October 2005)

  // A fully  optimized version of this code would replace the two sin 
  // calls with a pair of fast sin oscillators, for which stable fast 
  // two-multiply algorithms are well known. In the spirit of STK,
  // which favors clarity over performance, the optimization has 
  // not been made here.

  // Avoid a divide by zero, or use of a denormalized divisor 
  // at the sinc peak, which has a limiting value of m_ / p_.
  StkFloat tmp, denominator = sin( phase_ );
  if ( fabs(denominator) <= std::numeric_limits<StkFloat>::epsilon() )
    tmp = a_;
  else {
    tmp =  sin( m_ * phase_ );
    tmp /= p_ * denominator;
  }

  tmp += state_ - C2_;
  state_ = tmp * 0.995;

  phase_ += rate_;
  if ( phase_ >= PI ) phase_ -= PI;
    
  lastFrame_[0] = tmp;
	return lastFrame_[0];
}

inline StkFrames& BlitSaw :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "BlitSaw::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif


  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = BlitSaw::tick();

  return frames;
}

} // stk namespace

#endif
