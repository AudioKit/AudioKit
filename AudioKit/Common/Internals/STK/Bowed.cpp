/***************************************************/
/*! \class Bowed
    \brief STK bowed string instrument class.

    This class implements a bowed string model, a
    la Smith (1986), after McIntyre, Schumacher,
    Woodhouse (1983).

    This is a digital waveguide model, making its
    use possibly subject to patents held by
    Stanford University, Yamaha, and others.

    Control Change Numbers: 
       - Bow Pressure = 2
       - Bow Position = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Bow Velocity = 100
       - Frequency = 101
       - Volume = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
    Contributions by Esteban Maestre, 2011.
*/
/***************************************************/

#include "Bowed.h"
#include "SKINImsg.h"

namespace stk {

Bowed :: Bowed( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Bowed::Bowed: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  unsigned long nDelays = (unsigned long) ( Stk::sampleRate() / lowestFrequency );

  neckDelay_.setMaximumDelay( nDelays + 1 );
  neckDelay_.setDelay( 100.0 );

  bridgeDelay_.setMaximumDelay( nDelays + 1 );
  bridgeDelay_.setDelay( 29.0 );

  bowTable_.setSlope( 3.0 );
  bowTable_.setOffset( 0.001);
  bowDown_ = false;
  maxVelocity_ = 0.25;

  vibrato_.setFrequency( 6.12723 );
  vibratoGain_ = 0.0;

  stringFilter_.setPole( 0.75 - (0.2 * 22050.0 / Stk::sampleRate()) );
  stringFilter_.setGain( 0.95 );

  // Old single body filter
  //bodyFilter_.setResonance( 500.0, 0.85, true );
  //bodyFilter_.setGain( 0.2 );

  // New body filter provided by Esteban Maestre (cascade of second-order sections)
  bodyFilters_[0].setCoefficients( 1.0,  1.5667, 0.3133, -0.5509, -0.3925 );
  bodyFilters_[1].setCoefficients( 1.0, -1.9537, 0.9542, -1.6357, 0.8697 );
  bodyFilters_[2].setCoefficients( 1.0, -1.6683, 0.8852, -1.7674, 0.8735 );
  bodyFilters_[3].setCoefficients( 1.0, -1.8585, 0.9653, -1.8498, 0.9516 );
  bodyFilters_[4].setCoefficients( 1.0, -1.9299, 0.9621, -1.9354, 0.9590 );
  bodyFilters_[5].setCoefficients( 1.0, -1.9800, 0.9888, -1.9867, 0.9923 );

  adsr_.setAllTimes( 0.02, 0.005, 0.9, 0.01 );
    
  betaRatio_ = 0.127236;

  // Necessary to initialize internal variables.
  this->setFrequency( 220.0 );
  this->clear();
}

Bowed :: ~Bowed( void )
{
}

void Bowed :: clear( void )
{
  neckDelay_.clear();
  bridgeDelay_.clear();
  stringFilter_.clear();
  for ( int i=0; i<6; i++ ) bodyFilters_[i].clear();
}

void Bowed :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Bowed::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  // Delay = length - approximate filter delay.
  baseDelay_ = Stk::sampleRate() / frequency - 4.0;
  if ( baseDelay_ <= 0.0 ) baseDelay_ = 0.3;
  bridgeDelay_.setDelay( baseDelay_ * betaRatio_ ); 	     // bow to bridge length
  neckDelay_.setDelay( baseDelay_ * (1.0 - betaRatio_) );  // bow to nut (finger) length
}

void Bowed :: startBowing( StkFloat amplitude, StkFloat rate )
{
  if ( amplitude <= 0.0 || rate <= 0.0 ) {
    oStream_ << "Bowed::startBowing: one or more arguments is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setAttackRate( rate );
  adsr_.keyOn();
  maxVelocity_ = 0.03 + ( 0.2 * amplitude );
  bowDown_ = true;
}

void Bowed :: stopBowing( StkFloat rate )
{
  if ( rate <= 0.0 ) {
    oStream_ << "Bowed::stopBowing: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setReleaseRate( rate );
  adsr_.keyOff();
}

void Bowed :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->startBowing( amplitude, amplitude * 0.001 );
  this->setFrequency( frequency );
}

void Bowed :: noteOff( StkFloat amplitude )
{
  this->stopBowing( (1.0 - amplitude) * 0.005 );
}

void Bowed :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( value < 0 || ( number != 101 && value > 128.0 ) ) {
    oStream_ << "Bowed::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if ( number == __SK_BowPressure_ ) { // 2
		if ( normalizedValue > 0.0 ) bowDown_ = true;
		else bowDown_ = false;
		bowTable_.setSlope( 5.0 - (4.0 * normalizedValue) );
  }
  else if ( number == __SK_BowPosition_ ) { // 4
    betaRatio_ = normalizedValue;
    bridgeDelay_.setDelay( baseDelay_ * betaRatio_ );
    neckDelay_.setDelay( baseDelay_ * (1.0 - betaRatio_) );
  }
  else if ( number == __SK_ModFrequency_ ) // 11
    vibrato_.setFrequency( normalizedValue * 12.0 );
  else if ( number == __SK_ModWheel_ ) // 1
    vibratoGain_ = ( normalizedValue * 0.4 );
  else if ( number == 100 ) // 100: set instantaneous bow velocity
    adsr_.setTarget( normalizedValue );
	else if ( number == 101 ) // 101: set instantaneous value of frequency
		this->setFrequency( value );	  
  else if (number == __SK_AfterTouch_Cont_) // 128
    adsr_.setTarget( normalizedValue );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Bowed::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
