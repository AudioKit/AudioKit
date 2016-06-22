/***************************************************/
/*! \class Plucked
    \brief STK basic plucked string class.

    This class implements a simple plucked string
    physical model based on the Karplus-Strong
    algorithm.

    For a more advanced plucked string implementation,
    see the stk::Twang class.

    This is a digital waveguide model, making its
    use possibly subject to patents held by
    Stanford University, Yamaha, and others.
    There exist at least two patents, assigned to
    Stanford, bearing the names of Karplus and/or
    Strong.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Plucked.h"

namespace stk {

Plucked :: Plucked( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Plucked::Plucked: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  unsigned long delays = (unsigned long) ( Stk::sampleRate() / lowestFrequency );
  delayLine_.setMaximumDelay( delays + 1 );

  this->setFrequency( 220.0 );
}

Plucked :: ~Plucked( void )
{
}

void Plucked :: clear( void )
{
  delayLine_.clear();
  loopFilter_.clear();
  pickFilter_.clear();
}

void Plucked :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Plucked::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  // Delay = length - filter delay.
  StkFloat delay = ( Stk::sampleRate() / frequency ) - loopFilter_.phaseDelay( frequency );
  delayLine_.setDelay( delay );

  loopGain_ = 0.995 + (frequency * 0.000005);
  if ( loopGain_ >= 1.0 ) loopGain_ = 0.99999;
}

void Plucked :: pluck( StkFloat amplitude )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "Plucked::pluck: amplitude is out of range!";
    handleError( StkError::WARNING ); return;
  }

  pickFilter_.setPole( 0.999 - (amplitude * 0.15) );
  pickFilter_.setGain( amplitude * 0.5 );
  for ( unsigned long i=0; i<delayLine_.getDelay(); i++ )
    // Fill delay with noise additively with current contents.
    delayLine_.tick( 0.6 * delayLine_.lastOut() + pickFilter_.tick( noise_.tick() ) );
}

void Plucked :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  this->pluck( amplitude );
}

void Plucked :: noteOff( StkFloat amplitude )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "Plucked::noteOff: amplitude is out of range!";
    handleError( StkError::WARNING ); return;
  }

  loopGain_ = 1.0 - amplitude;
}

} // stk namespace
