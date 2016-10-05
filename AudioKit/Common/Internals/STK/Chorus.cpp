/***************************************************/
/*! \class Chorus
    \brief STK chorus effect class.

    This class implements a chorus effect.  It takes a monophonic
    input signal and produces a stereo output signal.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Chorus.h"

namespace stk {

Chorus :: Chorus( StkFloat baseDelay )
{
  lastFrame_.resize( 1, 2, 0.0 ); // resize lastFrame_ for stereo output
  delayLine_[0].setMaximumDelay( (unsigned long) (baseDelay * 1.414) + 2);
  delayLine_[0].setDelay( baseDelay );
  delayLine_[1].setMaximumDelay( (unsigned long) (baseDelay * 1.414) + 2);
  delayLine_[1].setDelay( baseDelay );
  baseLength_ = baseDelay;

  mods_[0].setFrequency( 0.2 );
  mods_[1].setFrequency( 0.222222 );
  modDepth_ = 0.05;
  effectMix_ = 0.5;
  this->clear();
}

void Chorus :: clear( void )
{
  delayLine_[0].clear();
  delayLine_[1].clear();
  lastFrame_[0] = 0.0;
  lastFrame_[1] = 0.0;
}

  void Chorus :: setModDepth( StkFloat depth )
{
  if ( depth < 0.0 || depth > 1.0 ) {
    oStream_ << "Chorus::setModDepth(): depth argument must be between 0.0 - 1.0!";
    handleError( StkError::WARNING ); return;
  }

    modDepth_ = depth;
};

void Chorus :: setModFrequency( StkFloat frequency )
{
  mods_[0].setFrequency( frequency );
  mods_[1].setFrequency( frequency * 1.1111 );
}

} // stk namespace
