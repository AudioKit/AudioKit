#ifndef STK_GUITAR_H
#define STK_GUITAR_H

#include "Stk.h"
#include "Twang.h"
#include "OnePole.h"
#include "OneZero.h"

namespace stk {

/***************************************************/
/*! \class Guitar
    \brief STK guitar model class.

    This class implements a guitar model with an arbitrary number of
    strings (specified during instantiation).  Each string is
    represented by an stk::Twang object.  The model supports commuted
    synthesis, as discussed by Smith and Karjalainen.  It also includes
    a basic body coupling model and supports feedback.

    This class does not attempt voice management.  Rather, most
    functions support a parameter to specify a particular string
    number and string (voice) management is assumed to occur
    externally.  Note that this class does not inherit from
    stk::Instrmnt because of API inconsistencies.

    This is a digital waveguide model, making its use possibly subject
    to patents held by Stanford University, Yamaha, and others.

    Control Change Numbers: 
       - Bridge Coupling Gain = 2
       - Pluck Position = 4
       - Loop Gain = 11
       - Coupling Filter Pole = 1
       - Pick Filter Pole = 128

    by Gary P. Scavone, 2012.
*/
/***************************************************/

class Guitar : public Stk
{
 public:
  //! Class constructor, specifying an arbitrary number of strings (default = 6).
  Guitar( unsigned int nStrings = 6, std::string bodyfile = "" );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set the string excitation, using either a soundfile or computed noise.
  /*!
     If no argument is provided, the std::string is empty, or an error
     occurs reading the file data, an enveloped noise signal will be
     generated for use as the pluck excitation.
   */
  void setBodyFile( std::string bodyfile = "" );

  //! Set the pluck position for one or all strings.
  /*!
     If the \c string argument is < 0, the pluck position is set
     for all strings.
  */
  void setPluckPosition( StkFloat position, int string = -1 );

  //! Set the loop gain for one or all strings.
  /*!
     If the \c string argument is < 0, the loop gain is set for all
     strings.
  */
  void setLoopGain( StkFloat gain, int string = -1 );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency, unsigned int string = 0 );

  //! Start a note with the given frequency and amplitude.
  /*!
     If the \c amplitude parameter is less than 0.2, the string will
     be undamped but it will not be "plucked."
   */
  void noteOn( StkFloat frequency, StkFloat amplitude, unsigned int string = 0 );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude, unsigned int string = 0 );

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  /*!
     If the \c string argument is < 0, then the control change is
     applied to all strings (if appropriate).
  */
  void controlChange( int number, StkFloat value, int string = -1 );

  //! Return the last computed output value.
  StkFloat lastOut( void ) { return lastFrame_[0]; };

  //! Take an optional input sample and compute one output sample.
  StkFloat tick( StkFloat input = 0.0 );

  //! Take a channel of the \c iFrames object as inputs to the class and write outputs to the \c oFrames object.
  /*!
    The \c iFrames object reference is returned.  Each channel
    argument must be less than the number of channels in the
    corresponding StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  //! Take a channel of the \c iFrames object as inputs to the effect and write outputs to the \c oFrames object.
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

  std::vector< stk::Twang > strings_;
  std::vector< int > stringState_; // 0 = off, 1 = decaying, 2 = on
  std::vector< unsigned int > decayCounter_;
  std::vector< unsigned int > filePointer_;
  std::vector< StkFloat > pluckGains_;

  OnePole   pickFilter_;
  OnePole   couplingFilter_;
  StkFloat  couplingGain_;
  StkFrames excitation_;
  StkFrames lastFrame_;
};

inline StkFloat Guitar :: tick( StkFloat input )
{
  StkFloat temp, output = 0.0;
  lastFrame_[0] /= strings_.size(); // evenly spread coupling across strings
  for ( unsigned int i=0; i<strings_.size(); i++ ) {
    if ( stringState_[i] ) {
      temp = input;
      // If pluckGain < 0.2, let string ring but don't pluck it.
      if ( filePointer_[i] < excitation_.frames() && pluckGains_[i] > 0.2 )
        temp += pluckGains_[i] * excitation_[filePointer_[i]++];
      temp += couplingGain_ * couplingFilter_.tick( lastFrame_[0] ); // bridge coupling
      output += strings_[i].tick( temp );
      // Check if string energy has decayed sufficiently to turn it off.
      if ( stringState_[i] == 1 ) {
        if ( fabs( strings_[i].lastOut() ) < 0.001 ) decayCounter_[i]++;
        else decayCounter_[i] = 0;
        if ( decayCounter_[i] > (unsigned int) floor( 0.1 * Stk::sampleRate() ) ) {
          stringState_[i] = 0;
          decayCounter_[i] = 0;
        }
      }
    }
  }

  return lastFrame_[0] = output;
}

inline StkFrames& Guitar :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Guitar::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = tick( *samples );

  return frames;
}

inline StkFrames& Guitar :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "Guitar::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop )
    *oSamples = tick( *iSamples );

  return iFrames;
}

} // stk namespace

#endif
