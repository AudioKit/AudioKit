/***************************************************/
/*! \class StifKarp
    \brief STK plucked stiff string instrument.

    This class implements a simple plucked string
    algorithm (Karplus Strong) with enhancements
    (Jaffe-Smith, Smith, and others), including
    string stiffness and pluck position controls.
    The stiffness is modeled with allpass filters.

    This is a digital waveguide model, making its
    use possibly subject to patents held by
    Stanford University, Yamaha, and others.

    Control Change Numbers:
       - Pickup Position = 4
       - String Sustain = 11
       - String Stretch = 1

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "StifKarp.h"
#include "SKINImsg.h"
#include <cmath>

namespace stk {

StifKarp :: StifKarp( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "StifKarp::StifKarp: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  unsigned long nDelays = (unsigned long) ( Stk::sampleRate() / lowestFrequency );
  delayLine_.setMaximumDelay( nDelays + 1 );
  combDelay_.setMaximumDelay( nDelays + 1 );

  pluckAmplitude_ = 0.3;
  pickupPosition_ = 0.4;

  stretching_ = 0.9999;
  baseLoopGain_ = 0.995;
  loopGain_ = 0.999;

  this->clear();
  this->setFrequency( 220.0 );
}

StifKarp :: ~StifKarp( void )
{
}

void StifKarp :: clear( void )
{
  delayLine_.clear();
  combDelay_.clear();
  filter_.clear();
}

void StifKarp :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "StifKarp::setFrequency: parameter is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  lastFrequency_ = frequency; 
  lastLength_ = Stk::sampleRate() / lastFrequency_;
  StkFloat delay = lastLength_ - 0.5;
  delayLine_.setDelay( delay );

  loopGain_ = baseLoopGain_ + (frequency * 0.000005);
  if (loopGain_ >= 1.0) loopGain_ = 0.99999;

  setStretch(stretching_);

  combDelay_.setDelay( 0.5 * pickupPosition_ * lastLength_ ); 
}

void StifKarp :: setStretch( StkFloat stretch )
{
  stretching_ = stretch;
  StkFloat coefficient;
  StkFloat freq = lastFrequency_ * 2.0;
  StkFloat dFreq = ( (0.5 * Stk::sampleRate()) - freq ) * 0.25;
  StkFloat temp = 0.5 + (stretch * 0.5);
  if ( temp > 0.9999 ) temp = 0.9999;
  for ( int i=0; i<4; i++ )	{
    coefficient = temp * temp;
    biquad_[i].setA2( coefficient );
    biquad_[i].setB0( coefficient );
    biquad_[i].setB2( 1.0 );

    coefficient = -2.0 * temp * cos(TWO_PI * freq / Stk::sampleRate());
    biquad_[i].setA1( coefficient );
    biquad_[i].setB1( coefficient );

    freq += dFreq;
  }
}

void StifKarp :: setPickupPosition( StkFloat position ) {

  if ( position < 0.0 || position > 1.0 ) {
    oStream_ << "StifKarp::setPickupPosition: parameter is out of range!";
    handleError( StkError::WARNING ); return;
  }

  // Set the pick position, which puts zeroes at position * length.
  pickupPosition_ = position;
  combDelay_.setDelay( 0.5 * pickupPosition_ * lastLength_ );
}

void StifKarp :: setBaseLoopGain( StkFloat aGain )
{
  baseLoopGain_ = aGain;
  loopGain_ = baseLoopGain_ + (lastFrequency_ * 0.000005);
  if ( loopGain_ > 0.99999 ) loopGain_ = (StkFloat) 0.99999;
}

void StifKarp :: pluck( StkFloat amplitude )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "StifKarp::pluck: amplitude is out of range!";
    handleError( StkError::WARNING ); return;
  }

  pluckAmplitude_ = amplitude;
  for ( unsigned long i=0; i<length_; i++ ) {
    // Fill delay with noise additively with current contents.
    delayLine_.tick( (delayLine_.lastOut() * 0.6) + 0.4 * noise_.tick() * pluckAmplitude_ );
    //delayLine_.tick( combDelay_.tick((delayLine_.lastOut() * 0.6) + 0.4 * noise->tick() * pluckAmplitude_) );
  }
}

void StifKarp :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  this->pluck( amplitude );
}

void StifKarp :: noteOff( StkFloat amplitude )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "StifKarp::noteOff: amplitude is out of range!";
    handleError( StkError::WARNING ); return;
  }

  loopGain_ =  (1.0 - amplitude) * 0.5;
}

void StifKarp :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Clarinet::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_PickPosition_) // 4
    this->setPickupPosition( normalizedValue );
  else if (number == __SK_StringDamping_) // 11
    this->setBaseLoopGain( 0.97 + (normalizedValue * 0.03) );
  else if (number == __SK_StringDetune_) // 1
    this->setStretch( 0.9 + (0.1 * (1.0 - normalizedValue)) );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "StifKarp::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
