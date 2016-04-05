/***************************************************/
/*! \class Resonate
    \brief STK noise driven formant filter.

    This instrument contains a noise source, which
    excites a biquad resonance filter, with volume
    controlled by an ADSR.

    Control Change Numbers:
       - Resonance Frequency (0-Nyquist) = 2
       - Pole Radii = 4
       - Notch Frequency (0-Nyquist) = 11
       - Zero Radii = 1
       - Envelope Gain = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Resonate.h"
#include "SKINImsg.h"

namespace stk {

Resonate :: Resonate( void )
{
  poleFrequency_ = 4000.0;
  poleRadius_ = 0.95;
  // Set the filter parameters.
  filter_.setResonance( poleFrequency_, poleRadius_, true );
  zeroFrequency_ = 0.0;
  zeroRadius_ = 0.0;
}  

Resonate :: ~Resonate( void )
{
}

void Resonate :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  adsr_.setTarget( amplitude );
  this->keyOn();
  this->setResonance( frequency, poleRadius_ );
}

void Resonate :: noteOff( StkFloat amplitude )
{
  this->keyOff();
}

void Resonate :: setResonance( StkFloat frequency, StkFloat radius )
{
  if ( frequency < 0.0 ) {
    oStream_ << "Resonate::setResonance: frequency parameter is less than zero!";
    handleError( StkError::WARNING ); return;
  }

  if ( radius < 0.0 || radius >= 1.0 ) {
    std::cerr << "Resonate::setResonance: radius parameter is out of range!";
    handleError( StkError::WARNING ); return;
  }

  poleFrequency_ = frequency;
  poleRadius_ = radius;
  filter_.setResonance( poleFrequency_, poleRadius_, true );
}

void Resonate :: setNotch( StkFloat frequency, StkFloat radius )
{
  if ( frequency < 0.0 ) {
    oStream_ << "Resonate::setNotch: frequency parameter is less than zero ... setting to 0.0!";
    handleError( StkError::WARNING ); return;
  }

  if ( radius < 0.0 ) {
    oStream_ << "Resonate::setNotch: radius parameter is less than 0.0!";
    handleError( StkError::WARNING ); return;
  }

  zeroFrequency_ = frequency;
  zeroRadius_ = radius;
  filter_.setNotch( zeroFrequency_, zeroRadius_ );
}

void Resonate :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Resonate::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == 2) // 2
    setResonance( normalizedValue * Stk::sampleRate() * 0.5, poleRadius_ );
  else if (number == 4) // 4
    setResonance( poleFrequency_, normalizedValue * 0.9999 );
  else if (number == 11) // 11
    this->setNotch( normalizedValue * Stk::sampleRate() * 0.5, zeroRadius_ );
  else if (number == 1)
    this->setNotch( zeroFrequency_, normalizedValue );
  else if (number == __SK_AfterTouch_Cont_) // 128
    adsr_.setTarget( normalizedValue );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Resonate::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
