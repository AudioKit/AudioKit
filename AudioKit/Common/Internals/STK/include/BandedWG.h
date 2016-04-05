#ifndef STK_BANDEDWG_H
#define STK_BANDEDWG_H

#include "Instrmnt.h"
#include "DelayL.h"
#include "BowTable.h"
#include "ADSR.h"
#include "BiQuad.h"

namespace stk {

/***************************************************/
/*! \class BandedWG
    \brief Banded waveguide modeling class.

    This class uses banded waveguide techniques to
    model a variety of sounds, including bowed
    bars, glasses, and bowls.  For more
    information, see Essl, G. and Cook, P. "Banded
    Waveguides: Towards Physical Modelling of Bar
    Percussion Instruments", Proceedings of the
    1999 International Computer Music Conference.

    Control Change Numbers: 
       - Bow Pressure = 2
       - Bow Motion = 4
       - Strike Position = 8 (not implemented)
       - Vibrato Frequency = 11
       - Gain = 1
       - Bow Velocity = 128
       - Set Striking = 64
       - Instrument Presets = 16
         - Uniform Bar = 0
         - Tuned Bar = 1
         - Glass Harmonica = 2
         - Tibetan Bowl = 3

    by Georg Essl, 1999 - 2004.
    Modified for STK 4.0 by Gary Scavone.
*/
/***************************************************/

const int MAX_BANDED_MODES = 20;

class BandedWG : public Instrmnt
{
 public:
  //! Class constructor.
  BandedWG( void );

  //! Class destructor.
  ~BandedWG( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set strike position (0.0 - 1.0).
  void setStrikePosition( StkFloat position );

  //! Select a preset.
  void setPreset( int preset );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Apply bow velocity/pressure to instrument with given amplitude and rate of increase.
  void startBowing( StkFloat amplitude, StkFloat rate );

  //! Decrease bow velocity/breath pressure with given rate of decrease.
  void stopBowing( StkFloat rate );

  //! Pluck the instrument with given amplitude.
  void pluck( StkFloat amp );

  //! Start a note with the given frequency and amplitude.
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

  bool doPluck_;
  bool trackVelocity_;
  int nModes_;
  int presetModes_;
  BowTable bowTable_;
  ADSR     adsr_;
  BiQuad   bandpass_[MAX_BANDED_MODES];
  DelayL   delay_[MAX_BANDED_MODES];
  StkFloat maxVelocity_;
  StkFloat modes_[MAX_BANDED_MODES];
  StkFloat frequency_;
  StkFloat baseGain_;
  StkFloat gains_[MAX_BANDED_MODES];
  StkFloat basegains_[MAX_BANDED_MODES];
  StkFloat excitation_[MAX_BANDED_MODES];
  StkFloat integrationConstant_;
  StkFloat velocityInput_;
  StkFloat bowVelocity_;
  StkFloat bowTarget_;
  StkFloat bowPosition_;
  StkFloat strikeAmp_;
  int strikePosition_;

};

inline StkFrames& BandedWG :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "BandedWG::tick(): channel and StkFrames arguments are incompatible!";
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
