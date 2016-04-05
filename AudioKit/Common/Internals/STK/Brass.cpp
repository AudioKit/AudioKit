/***************************************************/
/*! \class Brass
    \brief STK simple brass instrument class.

    This class implements a simple brass instrument
    waveguide model, a la Cook (TBone, HosePlayer).

    This is a digital waveguide model, making its
    use possibly subject to patents held by
    Stanford University, Yamaha, and others.

    Control Change Numbers: 
       - Lip Tension = 2
       - Slide Length = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Volume = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Brass.h"
#include "SKINImsg.h"
#include <cmath>

namespace stk {

Brass :: Brass( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Brass::Brass: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  unsigned long nDelays = (unsigned long) ( Stk::sampleRate() / lowestFrequency );
  delayLine_.setMaximumDelay( nDelays + 1 );

  lipFilter_.setGain( 0.03 );
  dcBlock_.setBlockZero();
  adsr_.setAllTimes( 0.005, 0.001, 1.0, 0.010 );

  vibrato_.setFrequency( 6.137 );
  vibratoGain_ = 0.0;
	maxPressure_ = 0.0;
  lipTarget_ = 0.0;

  this->clear();

  // This is necessary to initialize variables.
  this->setFrequency( 220.0 );
}

Brass :: ~Brass( void )
{
}

void Brass :: clear( void )
{
  delayLine_.clear();
  lipFilter_.clear();
  dcBlock_.clear();
}

void Brass :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Brass::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  // Fudge correction for filter delays.
  slideTarget_ = ( Stk::sampleRate() / frequency * 2.0 ) + 3.0;
  delayLine_.setDelay( slideTarget_ ); // play a harmonic

  lipTarget_ = frequency;
  lipFilter_.setResonance( frequency, 0.997 );
}

void Brass :: setLip( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Brass::setLip: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  lipFilter_.setResonance( frequency, 0.997 );
}

void Brass :: startBlowing( StkFloat amplitude, StkFloat rate )
{
  if ( amplitude <= 0.0 || rate <= 0.0 ) {
    oStream_ << "Brass::startBlowing: one or more arguments is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setAttackRate( rate );
  maxPressure_ = amplitude;
  adsr_.keyOn();
}

void Brass :: stopBlowing( StkFloat rate )
{
  if ( rate <= 0.0 ) {
    oStream_ << "Brass::stopBlowing: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setReleaseRate( rate );
  adsr_.keyOff();
}

void Brass :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  this->startBlowing( amplitude, amplitude * 0.001 );
}

void Brass :: noteOff( StkFloat amplitude )
{
  this->stopBlowing( amplitude * 0.005 );
}

void Brass :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Brass::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_LipTension_)	{ // 2
    StkFloat temp = lipTarget_ * pow( 4.0, (2.0 * normalizedValue) - 1.0 );
    this->setLip( temp );
  }
  else if (number == __SK_SlideLength_) // 4
    delayLine_.setDelay( slideTarget_ * (0.5 + normalizedValue) );
  else if (number == __SK_ModFrequency_) // 11
    vibrato_.setFrequency( normalizedValue * 12.0 );
  else if (number == __SK_ModWheel_ ) // 1
    vibratoGain_ = normalizedValue * 0.4;
  else if (number == __SK_AfterTouch_Cont_) // 128
    adsr_.setTarget( normalizedValue );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Brass::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
