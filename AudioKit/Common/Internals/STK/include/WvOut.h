#ifndef STK_WVOUT_H
#define STK_WVOUT_H

#include "Stk.h"

namespace stk {

/***************************************************/
/*! \class WvOut
    \brief STK audio output abstract base class.

    This class provides common functionality for a variety of audio
    data output subclasses.

    Currently, WvOut is non-interpolating and the output rate is
    always Stk::sampleRate().

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class WvOut : public Stk
{
 public:

  //! Default constructor.
  WvOut( void ) : frameCounter_(0), clipping_(false) {};

  //! Return the number of sample frames output.
  unsigned long getFrameCount( void ) const { return frameCounter_; };

  //! Return the number of seconds of data output.
  StkFloat getTime( void ) const { return (StkFloat) frameCounter_ / Stk::sampleRate(); };

  //! Returns \c true if clipping has been detected during output since instantiation or the last reset.
  bool clipStatus( void ) { return clipping_; };

  //! Reset the clipping status to \c false.
  void resetClipStatus( void ) { clipping_ = false; };

  //! Output a single sample to all channels in a sample frame.
  /*!
    An StkError is thrown if an output error occurs.
  */
  virtual void tick( const StkFloat sample ) = 0;

  //! Output the StkFrames data.
  virtual void tick( const StkFrames& frames ) = 0;

 protected:

  // Check for sample clipping and clamp.
  StkFloat& clipTest( StkFloat& sample );

  StkFrames data_;
  unsigned long frameCounter_;
  bool clipping_;

};

inline StkFloat& WvOut :: clipTest( StkFloat& sample )
{
  bool clip = false;
  if ( sample > 1.0 ) {
    sample = 1.0;
    clip = true;
  }
  else if ( sample < -1.0 ) {
    sample = -1.0;
    clip = true;
  }

  if ( clip == true && clipping_ == false ) {
    // First occurrence of clipping since instantiation or reset.
    clipping_ = true;
    oStream_ << "WvOut: data value(s) outside +-1.0 detected ... clamping at outer bound!";
    handleError( StkError::WARNING );
  }

  return sample;
}

} // stk namespace

#endif
