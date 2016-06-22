#ifndef STK_SINGWAVE_H
#define STK_SINGWAVE_H

#include "FileLoop.h"
#include "Modulate.h"
#include "Envelope.h"

namespace stk {

/***************************************************/
/*! \class SingWave
    \brief STK "singing" looped soundfile class.

    This class loops a specified soundfile and modulates it both
    periodically and randomly to produce a pitched musical sound, like
    a simple voice or violin.  In general, it is not be used alone
    because of "munchkinification" effects from pitch shifting.
    Within STK, it is used as an excitation source for other
    instruments.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class SingWave : public Generator
{
 public:
  //! Class constructor taking filename argument.
  /*!
    An StkError will be thrown if the file is not found, its format
    is unknown, or a read error occurs.  If the soundfile has no
    header, the second argument should be \e true and the file data
    will be assumed to consist of 16-bit signed integers in big-endian
    byte order at a sample rate of 22050 Hz.
  */
  SingWave( std::string fileName, bool raw = false );

  //! Class destructor.
  ~SingWave( void );

  //! Reset file to beginning.
  void reset( void ) { wave_.reset(); lastFrame_[0] = 0.0; };

  //! Normalize the file to a maximum of +-1.0.
  void normalize( void ) { wave_.normalize(); };

  //! Normalize the file to a maximum of \e +- peak.
  void normalize( StkFloat peak ) { wave_.normalize( peak ); };

  //! Set looping parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Set the vibrato frequency in Hz.
  void setVibratoRate( StkFloat rate ) { modulator_.setVibratoRate( rate ); };

  //! Set the vibrato gain.
  void setVibratoGain( StkFloat gain ) { modulator_.setVibratoGain( gain ); };

  //! Set the random-ness amount.
  void setRandomGain( StkFloat gain ) { modulator_.setRandomGain( gain ); };

  //! Set the sweep rate.
  void setSweepRate( StkFloat rate ) { sweepRate_ = rate; };

  //! Set the gain rate.
  void setGainRate( StkFloat rate ) { envelope_.setRate( rate ); };

  //! Set the gain target value.
  void setGainTarget( StkFloat target ) { envelope_.setTarget( target ); };

  //! Start a note.
  void noteOn( void ) { envelope_.keyOn(); };

  //! Stop a note.
  void noteOff( void ) { envelope_.keyOff(); };

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

  FileLoop wave_;
  Modulate modulator_;
  Envelope envelope_;
  Envelope pitchEnvelope_;
  StkFloat rate_;
  StkFloat sweepRate_;

};

inline StkFloat SingWave :: tick( void )
{
  // Set the wave rate.
  StkFloat newRate = pitchEnvelope_.tick();
  newRate += newRate * modulator_.tick();
  wave_.setRate( newRate );

  lastFrame_[0] = wave_.tick();
  lastFrame_[0] *= envelope_.tick();

  return lastFrame_[0];
}

inline StkFrames& SingWave :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "SingWave::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = SingWave::tick();

  return frames;
}

} // stk namespace

#endif
