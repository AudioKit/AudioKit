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

#include "Saxofony.h"
#include "SKINImsg.h"

namespace stk {

Saxofony :: Saxofony( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Saxofony::Saxofony: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  unsigned long nDelays = (unsigned long) ( Stk::sampleRate() / lowestFrequency );
  delays_[0].setMaximumDelay( nDelays + 1 );
  delays_[1].setMaximumDelay( nDelays + 1 );

  // Initialize blowing position to 0.2 of length.
  position_ = 0.2;

  reedTable_.setOffset( 0.7 );
  reedTable_.setSlope( 0.3 );

  vibrato_.setFrequency( 5.735 );

  outputGain_ = 0.3;
  noiseGain_ = 0.2;
  vibratoGain_ = 0.1;

  this->setFrequency( 220.0 );
  this->clear();
}

Saxofony :: ~Saxofony( void )
{
}

void Saxofony :: clear( void )
{
  delays_[0].clear();
  delays_[1].clear();
  filter_.clear();
}

void Saxofony :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Saxofony::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  // Account for filter delay and one sample "lastOut" delay.
  StkFloat delay = ( Stk::sampleRate() / frequency ) - filter_.phaseDelay( frequency ) - 1.0;
  delays_[0].setDelay( (1.0-position_) * delay );
  delays_[1].setDelay( position_ * delay );
}

void Saxofony :: setBlowPosition( StkFloat position )
{
  if ( position_ == position ) return;

  if ( position < 0.0 ) position_ = 0.0;
  else if ( position > 1.0 ) position_ = 1.0;
  else position_ = position;

  StkFloat totalDelay = delays_[0].getDelay();
  totalDelay += delays_[1].getDelay();

  delays_[0].setDelay( (1.0-position_) * totalDelay );
  delays_[1].setDelay( position_ * totalDelay );
}

void Saxofony :: startBlowing( StkFloat amplitude, StkFloat rate )
{
  if ( amplitude <= 0.0 || rate <= 0.0 ) {
    oStream_ << "Saxofony::startBlowing: one or more arguments is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  envelope_.setRate( rate );
  envelope_.setTarget( amplitude );
}

void Saxofony :: stopBlowing( StkFloat rate )
{
  if ( rate <= 0.0 ) {
    oStream_ << "Saxofony::stopBlowing: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  envelope_.setRate( rate );
  envelope_.setTarget( 0.0 );
}

void Saxofony :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  this->startBlowing( 0.55 + (amplitude * 0.30), amplitude * 0.005 );
  outputGain_ = amplitude + 0.001;
}

void Saxofony :: noteOff( StkFloat amplitude )
{
  this->stopBlowing( amplitude * 0.01 );
}

void Saxofony :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Saxofony::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_ReedStiffness_) // 2
    reedTable_.setSlope( 0.1 + (0.4 * normalizedValue) );
  else if (number == __SK_NoiseLevel_) // 4
    noiseGain_ = ( normalizedValue * 0.4 );
  else if (number == 29) // 29
    vibrato_.setFrequency( normalizedValue * 12.0 );
  else if (number == __SK_ModWheel_) // 1
    vibratoGain_ = ( normalizedValue * 0.5 );
  else if (number == __SK_AfterTouch_Cont_) // 128
    envelope_.setValue( normalizedValue );
  else if (number == 11) // 11
    this->setBlowPosition( normalizedValue );
  else if (number == 26) // reed table offset
    reedTable_.setOffset(0.4 + ( normalizedValue * 0.6));
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Saxofony::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
