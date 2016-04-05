#ifndef STK_FUNCTION_H
#define STK_FUNCTION_H

#include "Stk.h"

namespace stk {

/***************************************************/
/*! \class Function
    \brief STK abstract function parent class.

    This class provides common functionality for STK classes that
    implement tables or other types of input to output function
    mappings.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Function : public Stk
{
 public:
  //! Class constructor.
  Function( void ) { lastFrame_.resize( 1, 1, 0.0 ); };

  //! Return the last computed output sample.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Take one sample input and compute one sample of output.
  virtual StkFloat tick( StkFloat input ) = 0;

 protected:

  StkFrames lastFrame_;

};

} // stk namespace

#endif

