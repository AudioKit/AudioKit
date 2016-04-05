#ifndef STK_JETTABL_H
#define STK_JETTABL_H

#include "Function.h"

namespace stk {

/***************************************************/
/*! \class JetTable
    \brief STK jet table class.

    This class implements a flue jet non-linear
    function, computed by a polynomial calculation.
    Contrary to the name, this is not a "table".

    Consult Fletcher and Rossing, Karjalainen,
    Cook, and others for more information.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class JetTable : public Function
{
public:

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

};

inline StkFloat JetTable :: tick( StkFloat input )
{
  // Perform "table lookup" using a polynomial
  // calculation (x^3 - x), which approximates
  // the jet sigmoid behavior.
  lastFrame_[0] = input * (input * input - 1.0);

  // Saturate at +/- 1.0.
  if ( lastFrame_[0] > 1.0 ) lastFrame_[0] = 1.0;
  if ( lastFrame_[0] < -1.0 ) lastFrame_[0] = -1.0; 
  return lastFrame_[0];
}

inline StkFrames& JetTable :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "JetTable::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    *samples = *samples * (*samples * *samples - 1.0);
    if ( *samples > 1.0) *samples = 1.0;
    if ( *samples < -1.0) *samples = -1.0;
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& JetTable :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "JetTable::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    *oSamples = *oSamples * (*oSamples * *oSamples - 1.0);
    if ( *oSamples > 1.0) *oSamples = 1.0;
    if ( *oSamples < -1.0) *oSamples = -1.0;
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif
