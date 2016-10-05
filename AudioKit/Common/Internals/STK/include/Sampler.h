#ifndef STK_SAMPLER_H
#define STK_SAMPLER_H

#include "Instrmnt.h"
#include "ADSR.h"
#include "FileLoop.h"
#include "OnePole.h"

namespace stk {

/***************************************************/
/*! \class Sampler
    \brief STK sampling synthesis abstract base class.

    This instrument provides an ADSR envelope, a one-pole filter, and
    structures for an arbitrary number of attack and looped files.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Sampler : public Instrmnt
{
 public:
  //! Default constructor.
  Sampler( void );

  //! Class destructor.
  virtual ~Sampler( void );

  //! Set instrument parameters for a particular frequency.
  virtual void setFrequency( StkFloat frequency ) = 0;

  //! Initiate the envelopes with a key-on event and reset the attack waves.
  void keyOn( void );

  //! Signal a key-off event to the envelopes.
  void keyOff( void );

  //! Stop a note with the given amplitude (speed of decay).
  virtual void noteOff( StkFloat amplitude );

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  virtual void controlChange( int number, StkFloat value ) = 0;

  //! Compute and return one output sample.
  virtual StkFloat tick( unsigned int channel = 0 ) = 0;

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

  ADSR adsr_;
  std::vector<FileWvIn *> attacks_;
  std::vector<FileLoop *> loops_;
  OnePole filter_;
  StkFloat baseFrequency_;
  std::vector<StkFloat> attackRatios_;
  std::vector<StkFloat> loopRatios_;
  StkFloat attackGain_;
  StkFloat loopGain_;

};

} // stk namespace

#endif
