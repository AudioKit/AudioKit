/***************************************************/
/*! \class OnePole
    \brief STK one-pole filter class.

    This class implements a one-pole digital filter.  A method is
    provided for setting the pole position along the real axis of the
    z-plane while maintaining a constant peak filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "OnePole.h"

namespace stk {

OnePole :: OnePole( StkFloat thePole )
{
  b_.resize( 1 );
  a_.resize( 2 );
  a_[0] = 1.0;
  inputs_.resize( 1, 1, 0.0 );
  outputs_.resize( 2, 1, 0.0 );

  this->setPole( thePole );
}

OnePole :: ~OnePole()    
{
}

void OnePole :: setPole( StkFloat thePole )
{
  if ( std::abs( thePole ) >= 1.0 ) {
    oStream_ << "OnePole::setPole: argument (" << thePole << ") should be less than 1.0!";
    handleError( StkError::WARNING ); return;
  }

  // Normalize coefficients for peak unity gain.
  if ( thePole > 0.0 )
    b_[0] = (StkFloat) (1.0 - thePole);
  else
    b_[0] = (StkFloat) (1.0 + thePole);

  a_[1] = -thePole;
}

void OnePole :: setCoefficients( StkFloat b0, StkFloat a1, bool clearState )
{
  if ( std::abs( a1 ) >= 1.0 ) {
    oStream_ << "OnePole::setCoefficients: a1 argument (" << a1 << ") should be less than 1.0!";
    handleError( StkError::WARNING ); return;
  }

  b_[0] = b0;
  a_[1] = a1;

  if ( clearState ) this->clear();
}

} // stk namespace
