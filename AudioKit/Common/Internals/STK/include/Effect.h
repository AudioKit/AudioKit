#ifndef STK_EFFECT_H
#define STK_EFFECT_H

#include "Stk.h"
#include <cmath>

namespace stk {

/***************************************************/
/*! \class Effect
    \brief STK abstract effects parent class.

    This class provides common functionality for STK effects
    subclasses.  It is general enough to support both monophonic and
    polyphonic input/output classes.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Effect : public Stk
{
 public:
  //! Class constructor.
  Effect( void ) { lastFrame_.resize( 1, 1, 0.0 ); };

  //! Return the number of output channels for the class.
  unsigned int channelsOut( void ) const { return lastFrame_.channels(); };

  //! Return an StkFrames reference to the last output sample frame.
  const StkFrames& lastFrame( void ) const { return lastFrame_; };

  //! Reset and clear all internal state.
  virtual void clear() = 0;

  //! Set the mixture of input and "effected" levels in the output (0.0 = input only, 1.0 = effect only). 
  virtual void setEffectMix( StkFloat mix );

 protected:

  // Returns true if argument value is prime.
  bool isPrime( unsigned int number );

  StkFrames lastFrame_;
  StkFloat effectMix_;

};

inline void Effect :: setEffectMix( StkFloat mix )
{
  if ( mix < 0.0 ) {
    oStream_ << "Effect::setEffectMix: mix parameter is less than zero ... setting to zero!";
    handleError( StkError::WARNING );
    effectMix_ = 0.0;
  }
  else if ( mix > 1.0 ) {
    oStream_ << "Effect::setEffectMix: mix parameter is greater than 1.0 ... setting to one!";
    handleError( StkError::WARNING );
    effectMix_ = 1.0;
  }
  else
    effectMix_ = mix;
}

inline bool Effect :: isPrime( unsigned int number )
{
  if ( number == 2 ) return true;
  if ( number & 1 ) {
	  for ( int i=3; i<(int)sqrt((double)number)+1; i+=2 )
		  if ( (number % i) == 0 ) return false;
	  return true; // prime
	}
  else return false; // even
}

} // stk namespace

#endif

