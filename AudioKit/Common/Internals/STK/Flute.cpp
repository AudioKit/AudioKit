/***************************************************/
/*! \Class Flute
    \brief STK flute physical model class.

    This class implements a simple flute
    physical model, as discussed by Karjalainen,
    Smith, Waryznyk, etc.  The jet model uses
    a polynomial, a la Cook.

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    Control Change Numbers: 
       - Jet Delay = 2
       - Noise Gain = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Breath Pressure = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Flute.h"
#include "SKINImsg.h"

namespace stk {

Flute :: Flute( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Flute::Flute: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  unsigned long nDelays = (unsigned long) ( Stk::sampleRate() / lowestFrequency );
  boreDelay_.setMaximumDelay( nDelays + 1 );

  jetDelay_.setMaximumDelay( nDelays + 1 );
  jetDelay_.setDelay( 49.0 );

  vibrato_.setFrequency( 5.925 );
  filter_.setPole( 0.7 - ( 0.1 * 22050.0 / Stk::sampleRate() ) );
  dcBlock_.setBlockZero();

  adsr_.setAllTimes( 0.005, 0.01, 0.8, 0.010 );
  endReflection_ = 0.5;
  jetReflection_ = 0.5;
  noiseGain_     = 0.15;    // Breath pressure random component.
  vibratoGain_   = 0.05;    // Breath periodic vibrato component.
  jetRatio_      = 0.32;

	maxPressure_ = 0.0;
  this->clear();
  this->setFrequency( 220.0 );
}

Flute :: ~Flute( void )
{
}

void Flute :: clear( void )
{
  jetDelay_.clear();
  boreDelay_.clear();
  filter_.clear();
  dcBlock_.clear();
}

void Flute :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Flute::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  // We're overblowing here.
  lastFrequency_ = frequency * 0.66666;

  // Account for filter delay and one sample "lastOut" delay
  // (previously approximated as 2.0 samples).  The tuning is still
  // not perfect but I'm not sure why.  Also, we are not accounting
  // for the dc blocking filter delay.
  StkFloat delay = Stk::sampleRate() / lastFrequency_ - filter_.phaseDelay( lastFrequency_ ) - 1.0;

  boreDelay_.setDelay( delay );
  jetDelay_.setDelay( delay * jetRatio_ );
}

void Flute :: setJetDelay( StkFloat aRatio )
{
  jetRatio_ = aRatio;
  jetDelay_.setDelay( boreDelay_.getDelay() * aRatio ); // Scaled by ratio.
}

void Flute :: startBlowing( StkFloat amplitude, StkFloat rate )
{
  if ( amplitude <= 0.0 || rate <= 0.0 ) {
    oStream_ << "Flute::startBlowing: one or more arguments is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setAttackRate( rate );
  maxPressure_ = amplitude / (StkFloat) 0.8;
  adsr_.keyOn();
}

void Flute :: stopBlowing( StkFloat rate )
{
  if ( rate <= 0.0 ) {
    oStream_ << "Flute::stopBlowing: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setReleaseRate( rate );
  adsr_.keyOff();
}

void Flute :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  this->startBlowing( 1.1 + (amplitude * 0.20), amplitude * 0.02 );
  outputGain_ = amplitude + 0.001;
}

void Flute :: noteOff( StkFloat amplitude )
{
  this->stopBlowing( amplitude * 0.02 );
}


void Flute :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Flute::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_JetDelay_) // 2
    this->setJetDelay( (StkFloat) (0.08 + (0.48 * normalizedValue)) );
  else if (number == __SK_NoiseLevel_) // 4
    noiseGain_ = ( normalizedValue * 0.4);
  else if (number == __SK_ModFrequency_) // 11
    vibrato_.setFrequency( normalizedValue * 12.0);
  else if (number == __SK_ModWheel_) // 1
    vibratoGain_ = ( normalizedValue * 0.4 );
  else if (number == __SK_AfterTouch_Cont_) // 128
    adsr_.setTarget( normalizedValue );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Flute::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
