#ifndef STK_BLOWHOLE_H
#define STK_BLOWHOLE_H

#include "Instrmnt.h"
#include "DelayL.h"
#include "ReedTable.h"
#include "OneZero.h"
#include "PoleZero.h"
#include "Envelope.h"
#include "Noise.h"
#include "SineWave.h"

namespace stk {

/***************************************************/
/*! \class BlowHole
    \brief STK clarinet physical model with one
           register hole and one tonehole.

    This class is based on the clarinet model,
    with the addition of a two-port register hole
    and a three-port dynamic tonehole
    implementation, as discussed by Scavone and
    Cook (1998).

    In this implementation, the distances between
    the reed/register hole and tonehole/bell are
    fixed.  As a result, both the tonehole and
    register hole will have variable influence on
    the playing frequency, which is dependent on
    the length of the air column.  In addition,
    the highest playing freqeuency is limited by
    these fixed lengths.

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    Control Change Numbers: 
       - Reed Stiffness = 2
       - Noise Gain = 4
       - Tonehole State = 11
       - Register State = 1
       - Breath Pressure = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class BlowHole : public Instrmnt
{
 public:
  //! Class constructor.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  BlowHole( StkFloat lowestFrequency );

  //! Class destructor.
  ~BlowHole( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Set the tonehole state (0.0 = closed, 1.0 = fully open).
  void setTonehole( StkFloat newValue );

  //! Set the register hole state (0.0 = closed, 1.0 = fully open).
  void setVent( StkFloat newValue );

  //! Apply breath pressure to instrument with given amplitude and rate of increase.
  void startBlowing( StkFloat amplitude, StkFloat rate );

  //! Decrease breath pressure with given rate of decrease.
  void stopBlowing( StkFloat rate );

  //! Start a note with the given frequency and amplitude.
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude );

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

  DelayL    delays_[3];
  ReedTable reedTable_;
  OneZero   filter_;
  PoleZero  tonehole_;
  PoleZero  vent_;
  Envelope  envelope_;
  Noise     noise_;
  SineWave  vibrato_;

  StkFloat scatter_;
  StkFloat thCoeff_;
  StkFloat rhGain_;
  StkFloat outputGain_;
  StkFloat noiseGain_;
  StkFloat vibratoGain_;
};

  inline StkFloat BlowHole :: tick( unsigned int )
{
  StkFloat pressureDiff;
  StkFloat breathPressure;
  StkFloat temp;

  // Calculate the breath pressure (envelope + noise + vibrato)
  breathPressure = envelope_.tick(); 
  breathPressure += breathPressure * noiseGain_ * noise_.tick();
  breathPressure += breathPressure * vibratoGain_ * vibrato_.tick();

  // Calculate the differential pressure = reflected - mouthpiece pressures
  pressureDiff = delays_[0].lastOut() - breathPressure;

  // Do two-port junction scattering for register vent
  StkFloat pa = breathPressure + pressureDiff * reedTable_.tick( pressureDiff );
  StkFloat pb = delays_[1].lastOut();
  vent_.tick( pa+pb );

  lastFrame_[0] = delays_[0].tick( vent_.lastOut()+pb );
  lastFrame_[0] *= outputGain_;

  // Do three-port junction scattering (under tonehole)
  pa += vent_.lastOut();
  pb = delays_[2].lastOut();
  StkFloat pth = tonehole_.lastOut();
  temp = scatter_ * (pa + pb - 2 * pth);

  delays_[2].tick( filter_.tick(pa + temp) * -0.95 );
  delays_[1].tick( pb + temp );
  tonehole_.tick( pa + pb - pth + temp );

  return lastFrame_[0];
}

inline StkFrames& BlowHole :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "BlowHole::tick(): channel and StkFrames arguments are incompatible!";
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
