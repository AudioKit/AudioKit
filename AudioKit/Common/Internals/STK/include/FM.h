#ifndef STK_FM_H
#define STK_FM_H

#include "Instrmnt.h"
#include "ADSR.h"
#include "FileLoop.h"
#include "SineWave.h"
#include "TwoZero.h"

namespace stk {

/***************************************************/
/*! \class FM
    \brief STK abstract FM synthesis base class.

    This class controls an arbitrary number of
    waves and envelopes, determined via a
    constructor argument.

    Control Change Numbers: 
       - Control One = 2
       - Control Two = 4
       - LFO Speed = 11
       - LFO Depth = 1
       - ADSR 2 & 4 Target = 128

    The basic Chowning/Stanford FM patent expired
    in 1995, but there exist follow-on patents,
    mostly assigned to Yamaha.  If you are of the
    type who should worry about this (making
    money) worry away.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class FM : public Instrmnt
{
 public:
  //! Class constructor, taking the number of wave/envelope operators to control.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  FM( unsigned int operators = 4 );

  //! Class destructor.
  virtual ~FM( void );

  //! Load the rawwave filenames in waves.
  void loadWaves( const char **filenames );

  //! Set instrument parameters for a particular frequency.
  virtual void setFrequency( StkFloat frequency );

  //! Set the frequency ratio for the specified wave.
  void setRatio( unsigned int waveIndex, StkFloat ratio );

  //! Set the gain for the specified wave.
  void setGain( unsigned int waveIndex, StkFloat gain );

  //! Set the modulation speed in Hz.
  void setModulationSpeed( StkFloat mSpeed ) { vibrato_.setFrequency( mSpeed ); };

  //! Set the modulation depth.
  void setModulationDepth( StkFloat mDepth ) { modDepth_ = mDepth; };

  //! Set the value of control1.
  void setControl1( StkFloat cVal ) { control1_ = cVal * 2.0; };

  //! Set the value of control1.
  void setControl2( StkFloat cVal ) { control2_ = cVal * 2.0; };

  //! Start envelopes toward "on" targets.
  void keyOn( void );

  //! Start envelopes toward "off" targets.
  void keyOff( void );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude );

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  virtual void controlChange( int number, StkFloat value );

  //! Compute and return one output sample.
  virtual StkFloat tick( unsigned int ) = 0;

  //! Fill a channel of the StkFrames object with computed outputs.
  /*!
    The \c channel argument must be less than the number of
    channels in the StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  virtual StkFrames& tick( StkFrames& frames, unsigned int channel = 0 ) = 0;

 protected:

  std::vector<ADSR *> adsr_; 
  std::vector<FileLoop *> waves_;
  SineWave vibrato_;
  TwoZero  twozero_;
  unsigned int nOperators_;
  StkFloat baseFrequency_;
  std::vector<StkFloat> ratios_;
  std::vector<StkFloat> gains_;
  StkFloat modDepth_;
  StkFloat control1_;
  StkFloat control2_;
  StkFloat fmGains_[100];
  StkFloat fmSusLevels_[16];
  StkFloat fmAttTimes_[32];

};

} // stk namespace

#endif
