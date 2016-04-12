/***************************************************/
/*! \class TapDelay
    \brief STK non-interpolating tapped delay line class.

    This class implements a non-interpolating digital delay-line with
    an arbitrary number of output "taps".  If the maximum length and
    tap delays are not specified during instantiation, a fixed maximum
    length of 4095 and a single tap delay of zero is set.
    
    A non-interpolating delay line is typically used in fixed
    delay-length applications, such as for reverberation.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "TapDelay.h"

namespace stk {

TapDelay :: TapDelay( std::vector<unsigned long> taps, unsigned long maxDelay )
{
  // Writing before reading allows delays from 0 to length-1. 
  // If we want to allow a delay of maxDelay, we need a
  // delayline of length = maxDelay+1.
  if ( maxDelay < 1 ) {
    oStream_ << "TapDelay::TapDelay: maxDelay must be > 0!\n";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  for ( unsigned int i=0; i<taps.size(); i++ ) {
    if ( taps[i] > maxDelay ) {
      oStream_ << "TapDelay::TapDelay: maxDelay must be > than all tap delay values!\n";
      handleError( StkError::FUNCTION_ARGUMENT );
    }
  }

  if ( ( maxDelay + 1 ) > inputs_.size() )
    inputs_.resize( maxDelay + 1, 1, 0.0 );

  inPoint_ = 0;
  this->setTapDelays( taps );
}

TapDelay :: ~TapDelay()
{
}

void TapDelay :: setMaximumDelay( unsigned long delay )
{
  if ( delay < inputs_.size() ) return;

  for ( unsigned int i=0; i<delays_.size(); i++ ) {
    if ( delay < delays_[i] ) {
      oStream_ << "TapDelay::setMaximumDelay: argument (" << delay << ") less than a current tap delay setting (" << delays_[i] << ")!\n";
      handleError( StkError::WARNING ); return;
    }
  }

  inputs_.resize( delay + 1 );
}

void TapDelay :: setTapDelays( std::vector<unsigned long> taps )
{
  for ( unsigned int i=0; i<taps.size(); i++ ) {
    if ( taps[i] > inputs_.size() - 1 ) { // The value is too big.
      oStream_ << "TapDelay::setTapDelay: argument (" << taps[i] << ") greater than maximum!\n";
      handleError( StkError::WARNING ); return;
    }
  }

  if ( taps.size() != outPoint_.size() ) {
    outPoint_.resize( taps.size() );
    delays_.resize( taps.size() );
    lastFrame_.resize( 1, (unsigned int)taps.size(), 0.0 );
  }

  for ( unsigned int i=0; i<taps.size(); i++ ) {
    // read chases write
    if ( inPoint_ >= taps[i] ) outPoint_[i] = inPoint_ - taps[i];
    else outPoint_[i] = inputs_.size() + inPoint_ - taps[i];
    delays_[i] = taps[i];
  }
}

} // stk namespace

