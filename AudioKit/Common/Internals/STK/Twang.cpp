/***************************************************/
/*! \class Twang
    \brief STK enhanced plucked string class.

    This class implements an enhanced plucked-string
    physical model, a la Jaffe-Smith, Smith,
    Karjalainen and others.  It includes a comb
    filter to simulate pluck position.  The tick()
    function takes an input sample, which is added
    to the delayline input.  This can be used to
    implement commuted synthesis (if the input
    samples are derived from the impulse response of
    a body filter) or feedback (as in an electric
    guitar model).

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Twang.h"

namespace stk {

Twang :: Twang( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Twang::Twang: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  this->setLowestFrequency( lowestFrequency );

  std::vector<StkFloat> coefficients( 2, 0.5 );
  loopFilter_.setCoefficients( coefficients );

  loopGain_ = 0.995;
  pluckPosition_ = 0.4;
  this->setFrequency( 220.0 );
}

void Twang :: clear( void )
{
  delayLine_.clear();
  combDelay_.clear();
  loopFilter_.clear();
  lastOutput_ = 0.0;
}

void Twang :: setLowestFrequency( StkFloat frequency )
{
  unsigned long nDelays = (unsigned long) ( Stk::sampleRate() / frequency );
  delayLine_.setMaximumDelay( nDelays + 1 );
  combDelay_.setMaximumDelay( nDelays + 1 );
}

void Twang :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Twang::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  frequency_ = frequency;
  // Delay = length - filter delay.
  StkFloat delay = ( Stk::sampleRate() / frequency ) - loopFilter_.phaseDelay( frequency );
  delayLine_.setDelay( delay );

  this->setLoopGain( loopGain_ );

  // Set the pluck position, which puts zeroes at position * length.
  combDelay_.setDelay( 0.5 * pluckPosition_ * delay );
}

void Twang :: setLoopGain( StkFloat loopGain )
{
  if ( loopGain < 0.0 || loopGain >= 1.0 ) {
    oStream_ << "Twang::setLoopGain: parameter is out of range!";
    handleError( StkError::WARNING ); return;
  }

  loopGain_ = loopGain;
  StkFloat gain = loopGain_ + (frequency_ * 0.000005);
  if ( gain >= 1.0 ) gain = 0.99999;
  loopFilter_.setGain( gain );
}

void Twang :: setPluckPosition( StkFloat position )
{
  if ( position < 0.0 || position > 1.0 ) {
    oStream_ << "Twang::setPluckPosition: argument (" << position << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }

  pluckPosition_ = position;
}

} // stk namespace
