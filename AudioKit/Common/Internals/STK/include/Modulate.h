#ifndef STK_MODULATE_H
#define STK_MODULATE_H

#include "Generator.h"
#include "SineWave.h"
#include "Noise.h"
#include "OnePole.h"

namespace stk {

/***************************************************/
/*! \class Modulate
    \brief STK periodic/random modulator.

    This class combines random and periodic
    modulations to give a nice, natural human
    modulation function.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Modulate : public Generator
{
 public:
  //! Class constructor.
  /*!
    An StkError can be thrown if the rawwave path is incorrect.
   */
  Modulate( void );

  //! Class destructor.
  ~Modulate( void );

  //! Reset internal state.
  void reset( void ) { lastFrame_[0] = 0.0; };

  //! Set the periodic (vibrato) rate or frequency in Hz.
  void setVibratoRate( StkFloat rate ) { vibrato_.setFrequency( rate ); };

  //! Set the periodic (vibrato) gain.
  void setVibratoGain( StkFloat gain ) { vibratoGain_ = gain; };

  //! Set the random modulation gain.
  void setRandomGain( StkFloat gain );

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

  void sampleRateChanged( StkFloat newRate, StkFloat oldRate );

  SineWave vibrato_;
  Noise noise_;
  OnePole  filter_;
  StkFloat vibratoGain_;
  StkFloat randomGain_;
  unsigned int noiseRate_;
  unsigned int noiseCounter_;

};

inline StkFloat Modulate :: tick( void )
{
  // Compute periodic and random modulations.
  lastFrame_[0] = vibratoGain_ * vibrato_.tick();
  if ( noiseCounter_++ >= noiseRate_ ) {
    noise_.tick();
    noiseCounter_ = 0;
  }
  lastFrame_[0] += filter_.tick( noise_.lastOut() );
  return lastFrame_[0];
}

inline StkFrames& Modulate :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Modulate::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = Modulate::tick();

  return frames;
}

} // stk namespace

#endif
