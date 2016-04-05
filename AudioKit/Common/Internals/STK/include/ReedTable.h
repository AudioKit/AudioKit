#ifndef STK_REEDTABLE_H
#define STK_REEDTABLE_H

#include "Function.h"

namespace stk {

/***************************************************/
/*! \class ReedTable
    \brief STK reed table class.

    This class implements a simple one breakpoint,
    non-linear reed function, as described by
    Smith (1986).  This function is based on a
    memoryless non-linear spring model of the reed
    (the reed mass is ignored) which saturates when
    the reed collides with the mouthpiece facing.

    See McIntyre, Schumacher, & Woodhouse (1983),
    Smith (1986), Hirschman, Cook, Scavone, and
    others for more information.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class ReedTable : public Function
{
public:
  //! Default constructor.
  ReedTable( void ) : offset_(0.6), slope_(-0.8) {};

  //! Set the table offset value.
  /*!
    The table offset roughly corresponds to the size
    of the initial reed tip opening (a greater offset
    represents a smaller opening).
  */
  void setOffset( StkFloat offset ) { offset_ = offset; };

  //! Set the table slope value.
  /*!
   The table slope roughly corresponds to the reed
   stiffness (a greater slope represents a harder
   reed).
  */
  void setSlope( StkFloat slope ) { slope_ = slope; };

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

};

inline StkFloat ReedTable :: tick( StkFloat input )    
{
  // The input is differential pressure across the reed.
  lastFrame_[0] = offset_ + (slope_ * input);

  // If output is > 1, the reed has slammed shut and the
  // reflection function value saturates at 1.0.
  if ( lastFrame_[0] > 1.0) lastFrame_[0] = (StkFloat) 1.0;

  // This is nearly impossible in a physical system, but
  // a reflection function value of -1.0 corresponds to
  // an open end (and no discontinuity in bore profile).
  if ( lastFrame_[0] < -1.0) lastFrame_[0] = (StkFloat) -1.0;

  return lastFrame_[0];
}

inline StkFrames& ReedTable :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "ReedTable::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    *samples = offset_ + (slope_ * *samples);
    if ( *samples > 1.0) *samples = 1.0;
    if ( *samples < -1.0) *samples = -1.0;
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& ReedTable :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "ReedTable::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    *oSamples = offset_ + (slope_ * *iSamples);
    if ( *oSamples > 1.0) *oSamples = 1.0;
    if ( *oSamples < -1.0) *oSamples = -1.0;
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif
