/***************************************************/
/*! \class Delay
    \brief STK non-interpolating delay line class.

    This class implements a non-interpolating digital delay-line.  If
    the delay and maximum length are not specified during
    instantiation, a fixed maximum length of 4095 and a delay of zero
    is set.
    
    A non-interpolating delay line is typically used in fixed
    delay-length applications, such as for reverberation.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Delay.h"

namespace stk {

Delay :: Delay( unsigned long delay, unsigned long maxDelay )
{
  // Writing before reading allows delays from 0 to length-1. 
  // If we want to allow a delay of maxDelay, we need a
  // delay-line of length = maxDelay+1.
  if ( delay > maxDelay ) {
    oStream_ << "Delay::Delay: maxDelay must be > than delay argument!\n";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  if ( ( maxDelay + 1 ) > inputs_.size() )
    inputs_.resize( maxDelay + 1, 1, 0.0 );

  inPoint_ = 0;
  this->setDelay( delay );
}

Delay :: ~Delay()
{
}

void Delay :: setMaximumDelay( unsigned long delay )
{
  if ( delay < inputs_.size() ) return;
  inputs_.resize( delay + 1 );
}

void Delay :: setDelay( unsigned long delay )
{
  if ( delay > inputs_.size() - 1 ) { // The value is too big.
    oStream_ << "Delay::setDelay: argument (" << delay << ") greater than maximum!\n";
    handleError( StkError::WARNING ); return;
  }

  // read chases write
  if ( inPoint_ >= delay ) outPoint_ = inPoint_ - delay;
  else outPoint_ = inputs_.size() + inPoint_ - delay;
  delay_ = delay;
}

StkFloat Delay :: energy( void ) const
{
  unsigned long i;
  StkFloat e = 0;
  if ( inPoint_ >= outPoint_ ) {
    for ( i=outPoint_; i<inPoint_; i++ ) {
      StkFloat t = inputs_[i];
      e += t*t;
    }
  } else {
    for ( i=outPoint_; i<inputs_.size(); i++ ) {
      StkFloat t = inputs_[i];
      e += t*t;
    }
    for ( i=0; i<inPoint_; i++ ) {
      StkFloat t = inputs_[i];
      e += t*t;
    }
  }
  return e;
}

StkFloat Delay :: tapOut( unsigned long tapDelay )
{
  long tap = inPoint_ - tapDelay - 1;
  while ( tap < 0 ) // Check for wraparound.
    tap += inputs_.size();

  return inputs_[tap];
}

void Delay :: tapIn( StkFloat value, unsigned long tapDelay )
{
  long tap = inPoint_ - tapDelay - 1;
  while ( tap < 0 ) // Check for wraparound.
    tap += inputs_.size();

  inputs_[tap] = value;
}

StkFloat Delay :: addTo( StkFloat value, unsigned long tapDelay )
{
  long tap = inPoint_ - tapDelay - 1;
  while ( tap < 0 ) // Check for wraparound.
    tap += inputs_.size();

  return inputs_[tap]+= value;
}

} // stk namespace
