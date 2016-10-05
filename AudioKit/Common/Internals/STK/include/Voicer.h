#ifndef STK_VOICER_H
#define STK_VOICER_H

#include "Instrmnt.h"
#include <vector>

namespace stk {

/***************************************************/
/*! \class Voicer
    \brief STK voice manager class.

    This class can be used to manage a group of STK instrument
    classes.  Individual voices can be controlled via unique note
    tags.  Instrument groups can be controlled by group number.

    A previously constructed STK instrument class is linked with a
    voice manager using the addInstrument() function.  An optional
    group number argument can be specified to the addInstrument()
    function as well (default group = 0).  The voice manager does not
    delete any instrument instances ... it is the responsibility of
    the user to allocate and deallocate all instruments.

    The tick() function returns the mix of all sounding voices.  Each
    noteOn returns a unique tag (credits to the NeXT MusicKit), so you
    can send control changes to specific voices within an ensemble.
    Alternately, control changes can be sent to all voices in a given
    group.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Voicer : public Stk
{
 public:
  //! Class constructor taking an optional note decay time (in seconds).
  Voicer( StkFloat decayTime = 0.2 );

  //! Add an instrument with an optional group number to the voice manager.
  /*!
    A set of instruments can be grouped by group number and
    controlled via the functions that take a group number argument.
  */
  void addInstrument( Instrmnt *instrument, int group=0 );

  //! Remove the given instrument pointer from the voice manager's control.
  /*!
    It is important that any instruments which are to be deleted by
    the user while the voice manager is running be first removed from
    the manager's control via this function!!
  */
  void removeInstrument( Instrmnt *instrument );

  //! Initiate a noteOn event with the given note number and amplitude and return a unique note tag.
  /*!
    Send the noteOn message to the first available unused voice.
    If all voices are sounding, the oldest voice is interrupted and
    sent the noteOn message.  If the optional group argument is
    non-zero, only voices in that group are used.  If no voices are
    found for a specified non-zero group value, the function returns
    -1.  The amplitude value should be in the range 0.0 - 128.0.
  */
  long noteOn( StkFloat noteNumber, StkFloat amplitude, int group=0 );

  //! Send a noteOff to all voices having the given noteNumber and optional group (default group = 0).
  /*!
    The amplitude value should be in the range 0.0 - 128.0.
  */
  void noteOff( StkFloat noteNumber, StkFloat amplitude, int group=0 );

  //! Send a noteOff to the voice with the given note tag.
  /*!
    The amplitude value should be in the range 0.0 - 128.0.
  */
  void noteOff( long tag, StkFloat amplitude );

  //! Send a frequency update message to all voices assigned to the optional group argument (default group = 0).
  /*!
    The \e noteNumber argument corresponds to a MIDI note number, though it is a floating-point value and can range beyond the normal 0-127 range.
  */
  void setFrequency( StkFloat noteNumber, int group=0 );

  //! Send a frequency update message to the voice with the given note tag.
  /*!
    The \e noteNumber argument corresponds to a MIDI note number, though it is a floating-point value and can range beyond the normal 0-127 range.
  */
  void setFrequency( long tag, StkFloat noteNumber );

  //! Send a pitchBend message to all voices assigned to the optional group argument (default group = 0).
  void pitchBend( StkFloat value, int group=0 );

  //! Send a pitchBend message to the voice with the given note tag.
  void pitchBend( long tag, StkFloat value );

  //! Send a controlChange to all instruments assigned to the optional group argument (default group = 0).
  void controlChange( int number, StkFloat value, int group=0 );

  //! Send a controlChange to the voice with the given note tag.
  void controlChange( long tag, int number, StkFloat value );

  //! Send a noteOff message to all existing voices.
  void silence( void );

  //! Return the current number of output channels.
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

  //! Mix one sample frame of all sounding voices and return the specified \c channel value.
  /*!
    The \c channel argument must be less than the number of output
    channels, which can be determined with the channelsOut() function
    (the first channel is specified by 0).  However, range checking is
    only performed if _STK_DEBUG_ is defined during compilation, in
    which case an out-of-range value will trigger an StkError
    exception.
  */
  StkFloat tick( unsigned int channel = 0 );

  //! Fill the StkFrames argument with computed frames and return the same reference.
  /*!
    The number of channels in the StkFrames argument must equal
    the number of channels in the file data.  However, this is only
    checked if _STK_DEBUG_ is defined during compilation, in which
    case an incompatibility will trigger an StkError exception.  If no
    file data is loaded, the function does nothing (a warning will be
    issued if _STK_DEBUG_ is defined during compilation).
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

 protected:

  struct Voice {
    Instrmnt *instrument;
    long tag;
    StkFloat noteNumber;
    StkFloat frequency;
    int sounding;
    int group;

    // Default constructor.
    Voice()
      :instrument(0), tag(0), noteNumber(-1.0), frequency(0.0), sounding(0), group(0) {}
  };

  std::vector<Voice> voices_;
  long tags_;
  int muteTime_;
  StkFrames lastFrame_;
};

inline StkFloat Voicer :: lastOut( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= lastFrame_.channels() ) {
    oStream_ << "Voicer::lastOut(): channel argument is invalid!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  return lastFrame_[channel];
}


inline StkFloat Voicer :: tick( unsigned int channel )
{
  unsigned int j;
  for ( j=0; j<lastFrame_.channels(); j++ ) lastFrame_[j] = 0.0;
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].sounding != 0 ) {
      voices_[i].instrument->tick();
      for ( j=0; j<voices_[i].instrument->channelsOut(); j++ ) lastFrame_[j] += voices_[i].instrument->lastOut( j );
    }
    if ( voices_[i].sounding < 0 )
      voices_[i].sounding++;
    if ( voices_[i].sounding == 0 )
      voices_[i].noteNumber = -1;
  }

  return lastFrame_[channel];
}

inline StkFrames& Voicer :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Voicer::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - nChannels;
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    tick();
    for ( j=0; j<nChannels; j++ )
      *samples++ = lastFrame_[j];
  }

  return frames;
}

} // stk namespace

#endif
