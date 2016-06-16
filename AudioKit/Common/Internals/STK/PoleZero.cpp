/***************************************************/
/*! \class PoleZero
    \brief STK one-pole, one-zero filter class.

    This class implements a one-pole, one-zero digital filter.  A
    method is provided for creating an allpass filter with a given
    coefficient.  Another method is provided to create a DC blocking
    filter.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "PoleZero.h"

namespace stk {

PoleZero :: PoleZero()
{
  // Default setting for pass-through.
  b_.resize( 2, 0.0 );
  a_.resize( 2, 0.0 );
  b_[0] = 1.0;
  a_[0] = 1.0;
  inputs_.resize( 2, 1, 0.0 );
  outputs_.resize( 2, 1, 0.0 );
}

PoleZero :: ~PoleZero()
{
}

void PoleZero :: setCoefficients( StkFloat b0, StkFloat b1, StkFloat a1, bool clearState )
{
  if ( std::abs( a1 ) >= 1.0 ) {
    oStream_ << "PoleZero::setCoefficients: a1 argument (" << a1 << ") should be less than 1.0!";
    handleError( StkError::WARNING ); return;
  }

  b_[0] = b0;
  b_[1] = b1;
  a_[1] = a1;

  if ( clearState ) this->clear();
}

void PoleZero :: setAllpass( StkFloat coefficient )
{
  if ( std::abs( coefficient ) >= 1.0 ) {
    oStream_ << "PoleZero::setAllpass: argument (" << coefficient << ") makes filter unstable!";
    handleError( StkError::WARNING ); return;
  }

  b_[0] = coefficient;
  b_[1] = 1.0;
  a_[0] = 1.0; // just in case
  a_[1] = coefficient;
}

void PoleZero :: setBlockZero( StkFloat thePole )
{
  if ( std::abs( thePole ) >= 1.0 ) {
    oStream_ << "PoleZero::setBlockZero: argument (" << thePole << ") makes filter unstable!";
    handleError( StkError::WARNING ); return;
  }

  b_[0] = 1.0;
  b_[1] = -1.0;
  a_[0] = 1.0; // just in case
  a_[1] = -thePole;
}

} // stk namespace
