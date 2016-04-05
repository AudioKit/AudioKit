#ifndef STK_NOISE_H
#define STK_NOISE_H

#include "Generator.h"
#include <stdlib.h>

namespace stk {

/***************************************************/
/*! \class Noise
    \brief STK noise generator.

    Generic random number generation using the
    C rand() function.  The quality of the rand()
    function varies from one OS to another.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Noise : public Generator
{
public:

  //! Default constructor that can also take a specific seed value.
  /*!
    If the seed value is zero (the default value), the random number generator is
    seeded with the system time.
  */
  Noise( unsigned int seed = 0 );

  //! Seed the random number generator with a specific seed value.
  /*!
    If no seed is provided or the seed value is zero, the random
    number generator is seeded with the current system time.
  */
  void setSeed( unsigned int seed = 0 );

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Compute and return one output sample.
  StkFloat tick( void );

  //! Fill a channel of the StkFrames object with computed outputs.
  /*!
    The \c channel argument must be less than the number of
    channels in the StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

protected:

};

inline StkFloat Noise :: tick( void )
{
  return lastFrame_[0] = (StkFloat) ( 2.0 * rand() / (RAND_MAX + 1.0) - 1.0 );
}

inline StkFrames& Noise :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Noise::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = (StkFloat) ( 2.0 * rand() / (RAND_MAX + 1.0) - 1.0 );

  lastFrame_[0] = *(samples-hop);
  return frames;
}

} // stk namespace

#endif
