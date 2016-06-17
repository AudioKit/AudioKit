#ifndef STK_INSTRMNT_H
#define STK_INSTRMNT_H

#include "Stk.h"

namespace stk {

/***************************************************/
/*! \class Instrmnt
  \brief STK instrument abstract base class.

  This class provides a common interface for
  all STK instruments.

  by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Instrmnt : public Stk
{
 public:
  //! Class constructor.
  Instrmnt( void ) { lastFrame_.resize( 1, 1, 0.0 ); };

  //! Reset and clear all internal state (for subclasses).
  /*!
    Not all subclasses implement a clear() function.
  */
  virtual void clear( void ) {};

  //! Start a note with the given frequency and amplitude.
  virtual void noteOn( StkFloat frequency, StkFloat amplitude ) = 0;

  //! Stop a note with the given amplitude (speed of decay).
  virtual void noteOff( StkFloat amplitude ) = 0;

  //! Set instrument parameters for a particular frequency.
  virtual void setFrequency( StkFloat frequency );

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  virtual void controlChange(int number, StkFloat value);

  //! Return the number of output channels for the class.
  unsigned int channelsOut( void ) const { return lastFrame_.channels(); };

  //! Return an StkFrames reference to the last output sample frame.
  const StkFrames& lastFrame( void ) const { return lastFrame_; };

  //! Return the specified channel value of the last computed frame.
  /*!
    The \c channel argument must be less than the number of output
    channels, which can be determined with the channelsOut() function
    (the first channel is specified by 0).  However, range checking is
    only performed if _STK_DEBUG_ is defined during compilation, in
    which case an out-of-range value will trigger an StkError
    exception. \sa lastFrame()
  */
  StkFloat lastOut( unsigned int channel = 0 );

  //! Compute one sample frame and return the specified \c channel value.
  /*!
    For monophonic instruments, the \c channel argument is ignored.
  */
  virtual StkFloat tick( unsigned int channel = 0 ) = 0;

  //! Fill the StkFrames object with computed sample frames, starting at the specified channel.
  /*!
    The \c channel argument plus the number of output channels must
    be less than the number of channels in the StkFrames argument (the
    first channel is specified by 0).  However, range checking is only
    performed if _STK_DEBUG_ is defined during compilation, in which
    case an out-of-range value will trigger an StkError exception.
  */
  virtual StkFrames& tick( StkFrames& frames, unsigned int channel = 0 ) = 0;

 protected:

  StkFrames lastFrame_;

};

inline void Instrmnt :: setFrequency( StkFloat frequency )
{
  oStream_ << "Instrmnt::setFrequency: virtual setFrequency function call!";
  handleError( StkError::WARNING );
}

inline StkFloat Instrmnt :: lastOut( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= lastFrame_.channels() ) {
    oStream_ << "Instrmnt::lastOut(): channel argument is invalid!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  return lastFrame_[channel];
}

inline void Instrmnt :: controlChange( int number, StkFloat value )
{
  oStream_ << "Instrmnt::controlChange: virtual function call!";
  handleError( StkError::WARNING );
}

} // stk namespace

#endif
