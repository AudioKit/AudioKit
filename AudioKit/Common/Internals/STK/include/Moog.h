#ifndef STK_MOOG_H
#define STK_MOOG_H

#include "Sampler.h"
#include "FormSwep.h"

namespace stk {

/***************************************************/
/*! \class Moog
    \brief STK moog-like swept filter sampling synthesis class.

    This instrument uses one attack wave, one
    looped wave, and an ADSR envelope (inherited
    from the Sampler class) and adds two sweepable
    formant (FormSwep) filters.

    Control Change Numbers: 
       - Filter Q = 2
       - Filter Sweep Rate = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Gain = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Moog : public Sampler
{
 public:
  //! Class constructor.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  Moog( void );

  //! Class destructor.
  ~Moog( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Start a note with the given frequency and amplitude.
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Set the modulation (vibrato) speed in Hz.
  void setModulationSpeed( StkFloat mSpeed ) { loops_[1]->setFrequency( mSpeed ); };

  //! Set the modulation (vibrato) depth.
  void setModulationDepth( StkFloat mDepth ) { modDepth_ = mDepth * 0.5; };

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  void controlChange( int number, StkFloat value );

  //! Compute and return one output sample.
  StkFloat tick( unsigned int channel = 0 );

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

  FormSwep filters_[2];
  StkFloat modDepth_;
  StkFloat filterQ_;
  StkFloat filterRate_;

};

inline StkFloat Moog :: tick( unsigned int )
{
  StkFloat temp;

  if ( modDepth_ != 0.0 ) {
    temp = loops_[1]->tick() * modDepth_;    
    loops_[0]->setFrequency( baseFrequency_ * (1.0 + temp) );
  }

  temp = attackGain_ * attacks_[0]->tick();
  temp += loopGain_ * loops_[0]->tick();
  temp = filter_.tick( temp );
  temp *= adsr_.tick();
  temp = filters_[0].tick( temp );
  lastFrame_[0] = filters_[1].tick( temp );
  return lastFrame_[0] * 6.0;
}

inline StkFrames& Moog :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Moog::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - nChannels;
  if ( nChannels == 1 ) {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
      *samples++ = tick();
  }
  else {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
      *samples++ = tick();
      for ( j=1; j<nChannels; j++ )
        *samples++ = lastFrame_[j];
    }
  }

  return frames;
}

} // stk namespace

#endif
