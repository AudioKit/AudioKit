/***************************************************/
/*! \class Clarinet
    \brief STK clarinet physical model class.

    This class implements a simple clarinet
    physical model, as discussed by Smith (1986),
    McIntyre, Schumacher, Woodhouse (1983), and
    others.

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    Control Change Numbers: 
       - Reed Stiffness = 2
       - Noise Gain = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Breath Pressure = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Clarinet.h"
#include "SKINImsg.h"

namespace stk {

Clarinet :: Clarinet( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Clarinet::Clarinet: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  unsigned long nDelays = (unsigned long) ( 0.5 * Stk::sampleRate() / lowestFrequency );
  delayLine_.setMaximumDelay( nDelays + 1 );

  reedTable_.setOffset( 0.7 );
  reedTable_.setSlope( -0.3 );

  vibrato_.setFrequency( 5.735 );
  outputGain_ = 1.0;
  noiseGain_ = 0.2;
  vibratoGain_ = 0.1;

  this->setFrequency( 220.0 );
  this->clear();
}

Clarinet :: ~Clarinet( void )
{
}

void Clarinet :: clear( void )
{
  delayLine_.clear();
  filter_.tick( 0.0 );
}

void Clarinet :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Clarinet::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  // Account for filter delay and one sample "lastOut" delay.
  StkFloat delay = ( Stk::sampleRate() / frequency ) * 0.5 - filter_.phaseDelay( frequency ) - 1.0;
  delayLine_.setDelay( delay );
}

void Clarinet :: startBlowing( StkFloat amplitude, StkFloat rate )
{
  if ( amplitude <= 0.0 || rate <= 0.0 ) {
    oStream_ << "Clarinet::startBlowing: one or more arguments is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  envelope_.setRate( rate );
  envelope_.setTarget( amplitude );
}

void Clarinet :: stopBlowing( StkFloat rate )
{
  if ( rate <= 0.0 ) {
    oStream_ << "Clarinet::stopBlowing: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  envelope_.setRate( rate );
  envelope_.setTarget( 0.0 );
}

void Clarinet :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  this->startBlowing( 0.55 + (amplitude * 0.30), amplitude * 0.005 );
  outputGain_ = amplitude + 0.001;
}

void Clarinet :: noteOff( StkFloat amplitude )
{
  this->stopBlowing( amplitude * 0.01 );
}

void Clarinet :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Clarinet::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if ( number == __SK_ReedStiffness_ ) // 2
    reedTable_.setSlope( -0.44 + ( 0.26 * normalizedValue ) );
  else if ( number == __SK_NoiseLevel_ ) // 4
    noiseGain_ = ( normalizedValue * 0.4 );
  else if ( number == __SK_ModFrequency_ ) // 11
    vibrato_.setFrequency( normalizedValue * 12.0 );
  else if ( number == __SK_ModWheel_ ) // 1
    vibratoGain_ = ( normalizedValue * 0.5 );
  else if ( number == __SK_AfterTouch_Cont_ ) // 128
    envelope_.setValue( normalizedValue );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Clarinet::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
