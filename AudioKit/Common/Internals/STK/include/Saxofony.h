#ifndef STK_SAXOFONY_H
#define STK_SAXOFONY_H

#include "Instrmnt.h"
#include "DelayL.h"
#include "ReedTable.h"
#include "OneZero.h"
#include "Envelope.h"
#include "Noise.h"
#include "SineWave.h"

namespace stk {

/***************************************************/
/*! \class Saxofony
    \brief STK faux conical bore reed instrument class.

    This class implements a "hybrid" digital
    waveguide instrument that can generate a
    variety of wind-like sounds.  It has also been
    referred to as the "blowed string" model.  The
    waveguide section is essentially that of a
    string, with one rigid and one lossy
    termination.  The non-linear function is a
    reed table.  The string can be "blown" at any
    point between the terminations, though just as
    with strings, it is impossible to excite the
    system at either end.  If the excitation is
    placed at the string mid-point, the sound is
    that of a clarinet.  At points closer to the
    "bridge", the sound is closer to that of a
    saxophone.  See Scavone (2002) for more details.

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    Control Change Numbers: 
       - Reed Stiffness = 2
       - Reed Aperture = 26
       - Noise Gain = 4
       - Blow Position = 11
       - Vibrato Frequency = 29
       - Vibrato Gain = 1
       - Breath Pressure = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Saxofony : public Instrmnt
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  Saxofony( StkFloat lowestFrequency );

  //! Class destructor.
  ~Saxofony( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Set the "blowing" position between the air column terminations (0.0 - 1.0).
  void setBlowPosition( StkFloat aPosition );

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

  DelayL    delays_[2];
  ReedTable reedTable_;
  OneZero   filter_;
  Envelope  envelope_;
  Noise     noise_;
  SineWave vibrato_;

  StkFloat outputGain_;
  StkFloat noiseGain_;
  StkFloat vibratoGain_;
  StkFloat position_;

};

inline StkFloat Saxofony :: tick( unsigned int )
{
  StkFloat pressureDiff;
  StkFloat breathPressure;
  StkFloat temp;

  // Calculate the breath pressure (envelope + noise + vibrato)
  breathPressure = envelope_.tick(); 
  breathPressure += breathPressure * noiseGain_ * noise_.tick();
  breathPressure += breathPressure * vibratoGain_ * vibrato_.tick();

  temp = -0.95 * filter_.tick( delays_[0].lastOut() );
  lastFrame_[0] = temp - delays_[1].lastOut();
  pressureDiff = breathPressure - lastFrame_[0];
  delays_[1].tick( temp );
  delays_[0].tick( breathPressure - (pressureDiff * reedTable_.tick(pressureDiff)) - temp );

  lastFrame_[0] *= outputGain_;
  return lastFrame_[0];
}

inline StkFrames& Saxofony :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Saxofony::tick(): channel and StkFrames arguments are incompatible!";
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
