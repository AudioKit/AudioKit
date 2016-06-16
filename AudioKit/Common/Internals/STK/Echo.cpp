/***************************************************/
/*! \class Echo
    \brief STK echo effect class.

    This class implements an echo effect.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Echo.h"
#include <iostream>

namespace stk {

Echo :: Echo( unsigned long maximumDelay ) : Effect()
{
  this->setMaximumDelay( maximumDelay );
  delayLine_.setDelay( length_ >> 1 );
  effectMix_ = 0.5;
  this->clear();
}

void Echo :: clear( void )
{
  delayLine_.clear();
  lastFrame_[0] = 0.0;
}

void Echo :: setMaximumDelay( unsigned long delay )
{
  if ( delay == 0 ) {
    oStream_ << "Echo::setMaximumDelay: parameter cannot be zero!";
    handleError( StkError::WARNING ); return;
  }

  length_ = delay;
  delayLine_.setMaximumDelay( delay );
}

void Echo :: setDelay( unsigned long delay )
{
  if ( delay > length_ ) {
    oStream_ << "Echo::setDelay: parameter is greater than maximum delay length!";
    handleError( StkError::WARNING ); return;
  }

  delayLine_.setDelay( delay );
}

} // stk namespace
