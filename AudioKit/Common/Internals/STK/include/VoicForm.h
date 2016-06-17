#ifndef STK_VOICFORM_H
#define STK_VOICFORM_H

#include "Instrmnt.h"
#include "Envelope.h"
#include "Noise.h"
#include "SingWave.h"
#include "FormSwep.h"
#include "OnePole.h"
#include "OneZero.h"

namespace stk {

/***************************************************/
/*! \class VoicForm
    \brief Four formant synthesis instrument.

    This instrument contains an excitation singing
    wavetable (looping wave with random and
    periodic vibrato, smoothing on frequency,
    etc.), excitation noise, and four sweepable
    complex resonances.

    Measured formant data is included, and enough
    data is there to support either parallel or
    cascade synthesis.  In the floating point case
    cascade synthesis is the most natural so
    that's what you'll find here.

    Control Change Numbers: 
       - Voiced/Unvoiced Mix = 2
       - Vowel/Phoneme Selection = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Loudness (Spectral Tilt) = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class VoicForm : public Instrmnt
{
  public:
  //! Class constructor.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  VoicForm( void );

  //! Class destructor.
  ~VoicForm( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Set instrument parameters for the given phoneme.  Returns false if phoneme not found.
  bool setPhoneme( const char* phoneme );

  //! Set the voiced component gain.
  void setVoiced( StkFloat vGain ) { voiced_->setGainTarget(vGain); };

  //! Set the unvoiced component gain.
  void setUnVoiced( StkFloat nGain ) { noiseEnv_.setTarget(nGain); };

  //! Set the sweep rate for a particular formant filter (0-3).
  void setFilterSweepRate( unsigned int whichOne, StkFloat rate );

  //! Set voiced component pitch sweep rate.
  void setPitchSweepRate( StkFloat rate ) { voiced_->setSweepRate(rate); };

  //! Start the voice.
  void speak( void ) { voiced_->noteOn(); };

  //! Stop the voice.
  void quiet( void );

  //! Start a note with the given frequency and amplitude.
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude ) { this->quiet(); };

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

  SingWave *voiced_;
  Noise    noise_;
  Envelope noiseEnv_;
  FormSwep filters_[4];
  OnePole  onepole_;
  OneZero  onezero_;

};

inline StkFloat VoicForm :: tick( unsigned int )
{
  StkFloat temp;
  temp = onepole_.tick( onezero_.tick( voiced_->tick() ) );
  temp += noiseEnv_.tick() * noise_.tick();
  lastFrame_[0] = filters_[0].tick(temp);
  lastFrame_[0] += filters_[1].tick(temp);
  lastFrame_[0] += filters_[2].tick(temp);
  lastFrame_[0] += filters_[3].tick(temp);
  /*
    temp  += noiseEnv_.tick() * noise_.tick();
    lastFrame_[0]  = filters_[0].tick(temp);
    lastFrame_[0]  = filters_[1].tick(lastFrame_[0]);
    lastFrame_[0]  = filters_[2].tick(lastFrame_[0]);
    lastFrame_[0]  = filters_[3].tick(lastFrame_[0]);
  */
  return lastFrame_[0];
}

inline StkFrames& VoicForm :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "VoicForm::tick(): channel and StkFrames arguments are incompatible!";
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
