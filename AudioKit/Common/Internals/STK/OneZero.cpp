/***************************************************/
/*! \class OneZero
    \brief STK one-zero filter class.

    This class implements a one-zero digital filter.  A method is
    provided for setting the zero position along the real axis of the
    z-plane while maintaining a constant filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "OneZero.h"
#include <cmath>

namespace stk {

OneZero :: OneZero( StkFloat theZero )
{
  b_.resize( 2 );
  inputs_.resize( 2, 1, 0.0 );

  this->setZero( theZero );
}

OneZero :: ~OneZero( void )
{
}

void OneZero :: setZero( StkFloat theZero )
{
  // Normalize coefficients for unity gain.
  if ( theZero > 0.0 )
    b_[0] = 1.0 / ((StkFloat) 1.0 + theZero);
  else
    b_[0] = 1.0 / ((StkFloat) 1.0 - theZero);

  b_[1] = -theZero * b_[0];
}

void OneZero :: setCoefficients( StkFloat b0, StkFloat b1, bool clearState )
{
  b_[0] = b0;
  b_[1] = b1;

  if ( clearState ) this->clear();
}

} // stk namespace
