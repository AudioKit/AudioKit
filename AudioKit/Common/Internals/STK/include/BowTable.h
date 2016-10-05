#ifndef STK_BOWTABL_H
#define STK_BOWTABL_H

#include "Function.h"
#include <cmath>

namespace stk {

/***************************************************/
/*! \class BowTable
    \brief STK bowed string table class.

    This class implements a simple bowed string
    non-linear function, as described by Smith
    (1986).  The output is an instantaneous
    reflection coefficient value.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class BowTable : public Function
{
public:
  //! Default constructor.
  BowTable( void ) : offset_(0.0), slope_(0.1), minOutput_(0.01), maxOutput_(0.98) {};

  //! Set the table offset value.
  /*!
    The table offset is a bias which controls the
    symmetry of the friction.  If you want the
    friction to vary with direction, use a non-zero
    value for the offset.  The default value is zero.
  */
  void setOffset( StkFloat offset ) { offset_ = offset; };

  //! Set the table slope value.
  /*!
   The table slope controls the width of the friction
   pulse, which is related to bow force.
  */
  void setSlope( StkFloat slope ) { slope_ = slope; };

  //! Set the minimum table output value (0.0 - 1.0).
  void setMinOutput( StkFloat minimum ) { minOutput_ = minimum; };

  //! Set the maximum table output value (0.0 - 1.0).
  void setMaxOutput( StkFloat maximum ) { maxOutput_ = maximum; };

  //! Take one sample input and map to one sample of output.
  StkFloat tick( StkFloat input );

  //! Take a channel of the StkFrames object as inputs to the table and replace with corresponding outputs.
  /*!
    The StkFrames argument reference is returned.  The \c channel
    argument must be less than the number of channels in the
    StkFrames argument (the first channel is specified by 0).
    However, range checking is only performed if _STK_DEBUG_ is
    defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  //! Take a channel of the \c iFrames object as inputs to the table and write outputs to the \c oFrames object.
  /*!
    The \c iFrames object reference is returned.  Each channel
    argument must be less than the number of channels in the
    corresponding StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& iFrames, StkFrames &oFrames, unsigned int iChannel = 0, unsigned int oChannel = 0 );

protected:

  StkFloat offset_;
  StkFloat slope_;
  StkFloat minOutput_;
  StkFloat maxOutput_;

};

inline StkFloat BowTable :: tick( StkFloat input )
{
  // The input represents differential string vs. bow velocity.
  StkFloat sample  = input + offset_;  // add bias to input
  sample *= slope_;          // then scale it
  lastFrame_[0] = (StkFloat) fabs( (double) sample ) + (StkFloat) 0.75;
  lastFrame_[0] = (StkFloat) pow( lastFrame_[0], (StkFloat) -4.0 );

  // Set minimum threshold
  if ( lastFrame_[0] < minOutput_ ) lastFrame_[0] = minOutput_;

  // Set maximum threshold
  if ( lastFrame_[0] > maxOutput_ ) lastFrame_[0] = maxOutput_;

  return lastFrame_[0];
}

inline StkFrames& BowTable :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "BowTable::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    *samples = *samples + offset_;
    *samples *= slope_;
    *samples = (StkFloat) fabs( (double) *samples ) + 0.75;
    *samples = (StkFloat) pow( *samples, (StkFloat) -4.0 );
    if ( *samples > 1.0) *samples = 1.0;
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& BowTable :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "BowTable::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    *oSamples = *iSamples + offset_;
    *oSamples *= slope_;
    *oSamples = (StkFloat) fabs( (double) *oSamples ) + 0.75;
    *oSamples = (StkFloat) pow( *oSamples, (StkFloat) -4.0 );
    if ( *oSamples > 1.0) *oSamples = 1.0;
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif
