/***************************************************/
/*! \class Iir
    \brief STK general infinite impulse response filter class.

    This class provides a generic digital filter structure that can be
    used to implement IIR filters.  For filters containing only
    feedforward terms, the Fir class is slightly more efficient.

    In particular, this class implements the standard difference
    equation:

    a[0]*y[n] = b[0]*x[n] + ... + b[nb]*x[n-nb] -
                a[1]*y[n-1] - ... - a[na]*y[n-na]

    If a[0] is not equal to 1, the filter coeffcients are normalized
    by a[0].

    The \e gain parameter is applied at the filter input and does not
    affect the coefficient values.  The default gain value is 1.0.
    This structure results in one extra multiply per computed sample,
    but allows easy control of the overall filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Iir.h"

namespace stk {

Iir :: Iir()
{
  // The default constructor should setup for pass-through.
  b_.push_back( 1.0 );
  a_.push_back( 1.0 );

  inputs_.resize( 1, 1, 0.0 );
  outputs_.resize( 1, 1, 0.0 );
}

Iir :: Iir( std::vector<StkFloat> &bCoefficients, std::vector<StkFloat> &aCoefficients )
{
  // Check the arguments.
  if ( bCoefficients.size() == 0 || aCoefficients.size() == 0 ) {
    oStream_ << "Iir: a and b coefficient vectors must both have size > 0!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  if ( aCoefficients[0] == 0.0 ) {
    oStream_ << "Iir: a[0] coefficient cannot == 0!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  gain_ = 1.0;
  b_ = bCoefficients;
  a_ = aCoefficients;

  inputs_.resize( b_.size(), 1, 0.0 );
  outputs_.resize( a_.size(), 1, 0.0 );
  this->clear();
}

Iir :: ~Iir()
{
}

void Iir :: setCoefficients( std::vector<StkFloat> &bCoefficients, std::vector<StkFloat> &aCoefficients, bool clearState )
{
  this->setNumerator( bCoefficients, false );
  this->setDenominator( aCoefficients, false );

  if ( clearState ) this->clear();
}

void Iir :: setNumerator( std::vector<StkFloat> &bCoefficients, bool clearState )
{
  // Check the argument.
  if ( bCoefficients.size() == 0 ) {
    oStream_ << "Iir::setNumerator: coefficient vector must have size > 0!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  if ( b_.size() != bCoefficients.size() ) {
    b_ = bCoefficients;
    inputs_.resize( b_.size(), 1, 0.0 );
  }
  else {
    for ( unsigned int i=0; i<b_.size(); i++ ) b_[i] = bCoefficients[i];
  }

  if ( clearState ) this->clear();
}

void Iir :: setDenominator( std::vector<StkFloat> &aCoefficients, bool clearState )
{
  // Check the argument.
  if ( aCoefficients.size() == 0 ) {
    oStream_ << "Iir::setDenominator: coefficient vector must have size > 0!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  if ( aCoefficients[0] == 0.0 ) {
    oStream_ << "Iir::setDenominator: a[0] coefficient cannot == 0!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  if ( a_.size() != aCoefficients.size() ) {
    a_ = aCoefficients;
    outputs_.resize( a_.size(), 1, 0.0 );
  }
  else {
    for ( unsigned int i=0; i<a_.size(); i++ ) a_[i] = aCoefficients[i];
  }

  if ( clearState ) this->clear();

  // Scale coefficients by a[0] if necessary
  if ( a_[0] != 1.0 ) {
    unsigned int i;
    for ( i=0; i<b_.size(); i++ ) b_[i] /= a_[0];
    for ( i=1; i<a_.size(); i++ )  a_[i] /= a_[0];
  }
}

} // stk namespace
