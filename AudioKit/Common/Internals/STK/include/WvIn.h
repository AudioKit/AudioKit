#ifndef STK_WVIN_H
#define STK_WVIN_H

#include "Stk.h"

namespace stk {

/***************************************************/
/*! \class WvIn
    \brief STK audio input abstract base class.

    This class provides common functionality for a variety of audio
    data input subclasses.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class WvIn : public Stk
{
public:
  //! Return the number of audio channels in the data or stream.
  unsigned int channelsOut( void ) const { return data_.channels(); };

  //! Return an StkFrames reference to the last computed sample frame.
  /*!
    If no file data is loaded, an empty container is returned.
   */
  const StkFrames& lastFrame( void ) const { return lastFrame_; };

  //! Compute one sample frame and return the specified \c channel value.
  virtual StkFloat tick( unsigned int channel = 0 ) = 0;

  //! Fill the StkFrames object with computed sample frames, starting at the specified channel and return the same reference.
  virtual StkFrames& tick( StkFrames& frames, unsigned int channel = 0 ) = 0;

protected:

  StkFrames data_;
  StkFrames lastFrame_;

};

} // stk namespace

#endif
