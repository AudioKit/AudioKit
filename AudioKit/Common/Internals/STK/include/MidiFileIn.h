#ifndef STK_MIDIFILEIN_H
#define STK_MIDIFILEIN_H

#include "Stk.h"
#include <string>
#include <vector>
#include <fstream>
#include <sstream>

namespace stk {

/**********************************************************************/
/*! \class MidiFileIn
    \brief A standard MIDI file reading/parsing class.

    This class can be used to read events from a standard MIDI file.
    Event bytes are copied to a C++ vector and must be subsequently
    interpreted by the user.  The function getNextMidiEvent() skips
    meta and sysex events, returning only MIDI channel messages.
    Event delta-times are returned in the form of "ticks" and a
    function is provided to determine the current "seconds per tick".
    Tempo changes are internally tracked by the class and reflected in
    the values returned by the function getTickSeconds().

    by Gary P. Scavone, 2003 - 2010.
*/
/**********************************************************************/

class MidiFileIn : public Stk
{
 public:
  //! Default constructor.
  /*!
      If an error occurs while opening or parsing the file header, an
      StkError exception will be thrown.
  */
  MidiFileIn( std::string fileName );

  //! Class destructor.
  ~MidiFileIn();

  //! Return the MIDI file format (0, 1, or 2).
  int getFileFormat() const { return format_; };

  //! Return the number of tracks in the MIDI file.
  unsigned int getNumberOfTracks() const { return nTracks_; };

  //! Return the MIDI file division value from the file header.
  /*!
      Note that this value must be "parsed" in accordance with the
      MIDI File Specification.  In particular, if the MSB is set, the
      file uses time-code representations for delta-time values.
  */
  int getDivision() const { return division_; };

  //! Move the specified track event reader to the beginning of its track.
  /*!
      The relevant track tempo value is reset as well.  If an invalid
      track number is specified, an StkError exception will be thrown.
  */
  void rewindTrack( unsigned int track = 0 );

  //! Get the current value, in seconds, of delta-time ticks for the specified track.
  /*!
      This value can change as events are read (via "Set Tempo"
      Meta-Events).  Therefore, one should call this function after
      every call to getNextEvent() or getNextMidiEvent().  If an
      invalid track number is specified, an StkError exception will be
      thrown.
  */   
  double getTickSeconds( unsigned int track = 0 );

  //! Fill the user-provided vector with the next event in the specified track and return the event delta-time in ticks.
  /*!
      MIDI File events consist of a delta time and a sequence of event
      bytes.  This function returns the delta-time value and writes
      the subsequent event bytes directly to the event vector.  The
      user must parse the event bytes in accordance with the MIDI File
      Specification.  All returned MIDI channel events are complete
      ... a status byte is provided even when running status is used
      in the file.  If the track has reached its end, no bytes will be
      written and the event vector size will be zero.  If an invalid
      track number is specified or an error occurs while reading the
      file, an StkError exception will be thrown.
  */
  unsigned long getNextEvent( std::vector<unsigned char> *event, unsigned int track = 0 );

  //! Fill the user-provided vector with the next MIDI channel event in the specified track and return the event delta time in ticks.
  /*!
      All returned MIDI events are complete ... a status byte is
      provided even when running status is used in the file.  Meta and
      sysex events in the track are skipped though "Set Tempo" events
      are properly parsed for use by the getTickSeconds() function.
      If the track has reached its end, no bytes will be written and
      the event vector size will be zero.  If an invalid track number
      is specified or an error occurs while reading the file, an
      StkError exception will be thrown.
  */
  unsigned long getNextMidiEvent( std::vector<unsigned char> *midiEvent, unsigned int track = 0 );

 protected:

  // This protected class function is used for reading variable-length
  // MIDI file values. It is assumed that this function is called with
  // the file read pointer positioned at the start of a
  // variable-length value.  The function returns true if the value is
  // successfully parsed.  Otherwise, it returns false.
  bool readVariableLength( unsigned long *value );

  std::ifstream file_;
  unsigned int nTracks_;
  int format_;
  int division_;
  bool usingTimeCode_;
  std::vector<double> tickSeconds_;
  std::vector<long> trackPointers_;
  std::vector<long> trackOffsets_;
  std::vector<long> trackLengths_;
  std::vector<char> trackStatus_;

  // This structure and the following variables are used to save and
  // keep track of a format 1 tempo map (and the initial tickSeconds
  // parameter for formats 0 and 2).
  struct TempoChange { 
    unsigned long count;
    double tickSeconds;
  };
  std::vector<TempoChange> tempoEvents_;
  std::vector<unsigned long> trackCounters_;
  std::vector<unsigned int> trackTempoIndex_;
};

} // stk namespace

#endif
