#ifndef STK_MANDOLIN_H
#define STK_MANDOLIN_H

#include "Instrmnt.h"
#include "Twang.h"
#include "FileWvIn.h"

namespace stk {

/***************************************************/
/*! \class Mandolin
    \brief STK mandolin instrument model class.

    This class uses two "twang" models and "commuted
    synthesis" techniques to model a mandolin
    instrument.

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.  Commuted
    Synthesis, in particular, is covered by patents,
    granted, pending, and/or applied-for.  All are
    assigned to the Board of Trustees, Stanford
    University.  For information, contact the Office
    of Technology Licensing, Stanford University.

    Control Change Numbers: 
       - Body Size = 2
       - Pluck Position = 4
       - String Sustain = 11
       - String Detuning = 1
       - Microphone Position = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Mandolin : public Instrmnt
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  Mandolin( StkFloat lowestFrequency );

  //! Class destructor.
  ~Mandolin( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Detune the two strings by the given factor.  A value of 1.0 produces unison strings.
  void setDetune( StkFloat detune );

  //! Set the body size (a value of 1.0 produces the "default" size).
  void setBodySize( StkFloat size );

  //! Set the pluck or "excitation" position along the string (0.0 - 1.0).
  void setPluckPosition( StkFloat position );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Pluck the strings with the given amplitude (0.0 - 1.0) using the current frequency.
  void pluck( StkFloat amplitude );

  //! Pluck the strings with the given amplitude (0.0 - 1.0) and position (0.0 - 1.0).
  void pluck( StkFloat amplitude,StkFloat position );

  //! Start a note with the given frequency and amplitude (0.0 - 1.0).
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude );

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  void controlChange( int number, StkFloat value );

  //! Compute and return one output sample.
  StkFloat tick( unsigned int channel = 0 );

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

  Twang strings_[2];
  FileWvIn soundfile_[12];

  int mic_;
  StkFloat detuning_;
  StkFloat frequency_;
  StkFloat pluckAmplitude_;
};

inline StkFloat Mandolin :: tick( unsigned int )
{
  StkFloat temp = 0.0;
  if ( !soundfile_[mic_].isFinished() )
    temp = soundfile_[mic_].tick() * pluckAmplitude_;

  lastFrame_[0] = strings_[0].tick( temp );
  lastFrame_[0] += strings_[1].tick( temp );
  lastFrame_[0] *= 0.2;

  return lastFrame_[0];
}

inline StkFrames& Mandolin :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Mandolin::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - nChannels;
  if ( nChannels == 1 ) {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
      *samples++ = tick();
  }
  else {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
      *samples++ = tick();
      for ( j=1; j<nChannels; j++ )
        *samples++ = lastFrame_[j];
    }
  }

  return frames;
}

} // stk namespace

#endif
