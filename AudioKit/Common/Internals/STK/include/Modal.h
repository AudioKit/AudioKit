#ifndef STK_MODAL_H
#define STK_MODAL_H

#include "Instrmnt.h"
#include "Envelope.h"
#include "FileLoop.h"
#include "SineWave.h"
#include "BiQuad.h"
#include "OnePole.h"

namespace stk {

/***************************************************/
/*! \class Modal
    \brief STK resonance model abstract base class.

    This class contains an excitation wavetable,
    an envelope, an oscillator, and N resonances
    (non-sweeping BiQuad filters), where N is set
    during instantiation.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Modal : public Instrmnt
{
public:
  //! Class constructor, taking the desired number of modes to create.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  Modal( unsigned int modes = 4 );

  //! Class destructor.
  virtual ~Modal( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  virtual void setFrequency( StkFloat frequency );

  //! Set the ratio and radius for a specified mode filter.
  void setRatioAndRadius( unsigned int modeIndex, StkFloat ratio, StkFloat radius );

  //! Set the master gain.
  void setMasterGain( StkFloat aGain ) { masterGain_ = aGain; };

  //! Set the direct gain.
  void setDirectGain( StkFloat aGain ) { directGain_ = aGain; };

  //! Set the gain for a specified mode filter.
  void setModeGain( unsigned int modeIndex, StkFloat gain );

  //! Initiate a strike with the given amplitude (0.0 - 1.0).
  virtual void strike( StkFloat amplitude );

  //! Damp modes with a given decay factor (0.0 - 1.0).
  void damp( StkFloat amplitude );

  //! Start a note with the given frequency and amplitude.
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude );

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  virtual void controlChange( int number, StkFloat value ) = 0;

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

  Envelope envelope_; 
  FileWvIn *wave_;
  BiQuad **filters_;
  OnePole  onepole_;
  SineWave vibrato_;

  unsigned int nModes_;
  std::vector<StkFloat> ratios_;
  std::vector<StkFloat> radii_;

  StkFloat vibratoGain_;
  StkFloat masterGain_;
  StkFloat directGain_;
  StkFloat stickHardness_;
  StkFloat strikePosition_;
  StkFloat baseFrequency_;
};

inline StkFloat Modal :: tick( unsigned int )
{
  StkFloat temp = masterGain_ * onepole_.tick( wave_->tick() * envelope_.tick() );

  StkFloat temp2 = 0.0;
  for ( unsigned int i=0; i<nModes_; i++ )
    temp2 += filters_[i]->tick(temp);

  temp2  -= temp2 * directGain_;
  temp2 += directGain_ * temp;

  if ( vibratoGain_ != 0.0 ) {
    // Calculate AM and apply to master out
    temp = 1.0 + ( vibrato_.tick() * vibratoGain_ );
    temp2 = temp * temp2;
  }
    
  lastFrame_[0] = temp2;
  return lastFrame_[0];
}

inline StkFrames& Modal :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Modal::tick(): channel and StkFrames arguments are incompatible!";
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
