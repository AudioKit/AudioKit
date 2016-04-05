/***************************************************/
/*! \class Fir
    \brief STK general finite impulse response filter class.

    This class provides a generic digital filter structure that can be
    used to implement FIR filters.  For filters with feedback terms,
    the Iir class should be used.

    In particular, this class implements the standard difference
    equation:

    y[n] = b[0]*x[n] + ... + b[nb]*x[n-nb]

    The \e gain parameter is applied at the filter input and does not
    affect the coefficient values.  The default gain value is 1.0.
    This structure results in one extra multiply per computed sample,
    but allows easy control of the overall filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Fir.h"
#include <cmath>

namespace stk {

Fir :: Fir()
{
  // The default constructor should setup for pass-through.
  b_.push_back( 1.0 );

  inputs_.resize( 1, 1, 0.0 );
}

Fir :: Fir( std::vector<StkFloat> &coefficients )
{
  // Check the arguments.
  if ( coefficients.size() == 0 ) {
    oStream_ << "Fir: coefficient vector must have size > 0!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  gain_ = 1.0;
  b_ = coefficients;

  inputs_.resize( b_.size(), 1, 0.0 );
  this->clear();
}

Fir :: ~Fir()
{
}

void Fir :: setCoefficients( std::vector<StkFloat> &coefficients, bool clearState )
{
  // Check the argument.
  if ( coefficients.size() == 0 ) {
    oStream_ << "Fir::setCoefficients: coefficient vector must have size > 0!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  if ( b_.size() != coefficients.size() ) {
    b_ = coefficients;
    inputs_.resize( b_.size(), 1, 0.0 );
  }
  else {
    for ( unsigned int i=0; i<b_.size(); i++ ) b_[i] = coefficients[i];
  }

  if ( clearState ) this->clear();
}

} // stk namespace
