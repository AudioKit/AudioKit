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

#include "MidiFileIn.h"
#include <cstring>
#include <iostream>

namespace stk {

MidiFileIn :: MidiFileIn( std::string fileName )
{
  // Attempt to open the file.
  file_.open( fileName.c_str(), std::ios::in | std::ios::binary );
  if ( !file_ ) {
    oStream_ << "MidiFileIn: error opening or finding file (" <<  fileName << ").";
    handleError( StkError::FILE_NOT_FOUND );
  }

  // Parse header info.
  char chunkType[4];
  char buffer[4];
  SINT32 *length;
  if ( !file_.read( chunkType, 4 ) ) goto error;
  if ( !file_.read( buffer, 4 ) ) goto error;
#ifdef __LITTLE_ENDIAN__
  swap32((unsigned char *)&buffer);
#endif
  length = (SINT32 *) &buffer;
  if ( strncmp( chunkType, "MThd", 4 ) || ( *length != 6 ) ) {
    oStream_ << "MidiFileIn: file (" <<  fileName << ") does not appear to be a MIDI file!";
    handleError( StkError::FILE_UNKNOWN_FORMAT );
  }

  // Read the MIDI file format.
  SINT16 *data;
  if ( !file_.read( buffer, 2 ) ) goto error;
#ifdef __LITTLE_ENDIAN__
  swap16((unsigned char *)&buffer);
#endif
  data = (SINT16 *) &buffer;
  if ( *data < 0 || *data > 2 ) {
    oStream_ << "MidiFileIn: the file (" <<  fileName << ") format is invalid!";
    handleError( StkError::FILE_ERROR );
  }
  format_ = *data;

  // Read the number of tracks.
  if ( !file_.read( buffer, 2 ) ) goto error;
#ifdef __LITTLE_ENDIAN__
  swap16((unsigned char *)&buffer);
#endif
  if ( format_ == 0 && *data != 1 ) {
    oStream_ << "MidiFileIn: invalid number of tracks (>1) for a file format = 0!";
    handleError( StkError::FILE_ERROR );
  }
  nTracks_ = *data;

  // Read the beat division.
  if ( !file_.read( buffer, 2 ) ) goto error;
#ifdef __LITTLE_ENDIAN__
  swap16((unsigned char *)&buffer);
#endif
  division_ = (int) *data;
  double tickrate;
  usingTimeCode_ = false;
  if ( *data & 0x8000 ) {
    // Determine ticks per second from time-code formats.
    tickrate = (double) -(*data & 0x7F00);
    // If frames per second value is 29, it really should be 29.97.
    if ( tickrate == 29.0 ) tickrate = 29.97;
    tickrate *= (*data & 0x00FF);
    usingTimeCode_ = true;
  }
  else {
    tickrate = (double) (*data & 0x7FFF); // ticks per quarter note
  }

  // Now locate the track offsets and lengths.  If not using time
  // code, we can initialize the "tick time" using a default tempo of
  // 120 beats per minute.  We will then check for tempo meta-events
  // afterward.
  unsigned int i;
  for ( i=0; i<nTracks_; i++ ) {
    if ( !file_.read( chunkType, 4 ) ) goto error;
    if ( strncmp( chunkType, "MTrk", 4 ) ) goto error;
    if ( !file_.read( buffer, 4 ) ) goto error;
#ifdef __LITTLE_ENDIAN__
  swap32((unsigned char *)&buffer);
#endif
    length = (SINT32 *) &buffer;
    trackLengths_.push_back( *length );
    trackOffsets_.push_back( (long) file_.tellg() );
    trackPointers_.push_back( (long) file_.tellg() );
    trackStatus_.push_back( 0 );
    file_.seekg( *length, std::ios_base::cur );
    if ( usingTimeCode_ ) tickSeconds_.push_back( (double) (1.0 / tickrate) );
    else tickSeconds_.push_back( (double) (0.5 / tickrate) );
  }

  // Save the initial tickSeconds parameter.
  TempoChange tempoEvent;
  tempoEvent.count = 0;
  tempoEvent.tickSeconds = tickSeconds_[0];
  tempoEvents_.push_back( tempoEvent );

  // If format 1 and not using time code, parse and save the tempo map
  // on track 0.
  if ( format_ == 1 && !usingTimeCode_ ) {
    std::vector<unsigned char> event;
    unsigned long value, count;

    // We need to temporarily change the usingTimeCode_ value here so
    // that the getNextEvent() function doesn't try to check the tempo
    // map (which we're creating here).
    usingTimeCode_ = true;
    count = getNextEvent( &event, 0 );
    while ( event.size() ) {
      if ( ( event.size() == 6 ) && ( event[0] == 0xff ) &&
           ( event[1] == 0x51 ) && ( event[2] == 0x03 ) ) {
        tempoEvent.count = count;
        value = ( event[3] << 16 ) + ( event[4] << 8 ) + event[5];
        tempoEvent.tickSeconds = (double) (0.000001 * value / tickrate);
        if ( count > tempoEvents_.back().count )
          tempoEvents_.push_back( tempoEvent );
        else
          tempoEvents_.back() = tempoEvent;
      }
      count += getNextEvent( &event, 0 );
    }
    rewindTrack( 0 );
    for ( unsigned int i=0; i<nTracks_; i++ ) {
      trackCounters_.push_back( 0 );
      trackTempoIndex_.push_back( 0 );
    }
    // Change the time code flag back!
    usingTimeCode_ = false;
  }

  return;

 error:
  oStream_ << "MidiFileIn: error reading from file (" <<  fileName << ").";
  handleError( StkError::FILE_ERROR );
}

MidiFileIn :: ~MidiFileIn()
{
  // An ifstream object implicitly closes itself during destruction
  // but we'll make an explicit call to "close" anyway.
  file_.close(); 
}

void MidiFileIn :: rewindTrack( unsigned int track )
{
  if ( track >= nTracks_ ) {
    oStream_ << "MidiFileIn::getNextEvent: invalid track argument (" <<  track << ").";
    handleError( StkError::WARNING ); return;
  }

  trackPointers_[track] = trackOffsets_[track];
  trackStatus_[track] = 0;
  tickSeconds_[track] = tempoEvents_[0].tickSeconds;
}

double MidiFileIn :: getTickSeconds( unsigned int track )
{
  // Return the current tick value in seconds for the given track.
  if ( track >= nTracks_ ) {
    oStream_ << "MidiFileIn::getTickSeconds: invalid track argument (" <<  track << ").";
    handleError( StkError::WARNING ); return 0.0;
  }

  return tickSeconds_[track];
}

unsigned long MidiFileIn :: getNextEvent( std::vector<unsigned char> *event, unsigned int track )
{
  // Fill the user-provided vector with the next event in the
  // specified track (default = 0) and return the event delta time in
  // ticks.  This function assumes that the stored track pointer is
  // positioned at the start of a track event.  If the track has
  // reached its end, the event vector size will be zero.
  //
  // If we have a format 0 or 2 file and we're not using timecode, we
  // should check every meta-event for tempo changes and make
  // appropriate updates to the tickSeconds_ parameter if so.
  //
  // If we have a format 1 file and we're not using timecode, keep a
  // running sum of ticks for each track and update the tickSeconds_
  // parameter as needed based on the stored tempo map.

  event->clear();
  if ( track >= nTracks_ ) {
    oStream_ << "MidiFileIn::getNextEvent: invalid track argument (" <<  track << ").";
    handleError( StkError::WARNING ); return 0;
  }

  // Check for the end of the track.
  if ( (trackPointers_[track] - trackOffsets_[track]) >= trackLengths_[track] )
    return 0;

  unsigned long ticks = 0, bytes = 0;
  bool isTempoEvent = false;

  // Read the event delta time.
  file_.seekg( trackPointers_[track], std::ios_base::beg );
  if ( !readVariableLength( &ticks ) ) goto error;

  // Parse the event stream to determine the event length.
  unsigned char c;
  if ( !file_.read( (char *)&c, 1 ) ) goto error;
  switch ( c ) {

  case 0xFF: // A Meta-Event
    unsigned long position;
    trackStatus_[track] = 0;
    event->push_back( c );
    if ( !file_.read( (char *)&c, 1 ) ) goto error;
    event->push_back( c );
    if ( format_ != 1 && ( c == 0x51 ) ) isTempoEvent = true;
    position = (unsigned long)file_.tellg();
    if ( !readVariableLength( &bytes ) ) goto error;
    bytes += ( (unsigned long)file_.tellg() - position );
    file_.seekg( position, std::ios_base::beg );
    break;

  case 0xF0:
  case 0xF7: // The start or continuation of a Sysex event
    trackStatus_[track] = 0;
    event->push_back( c );
    position = (unsigned long)file_.tellg();
    if ( !readVariableLength( &bytes ) ) goto error;
    bytes += ( (unsigned long)file_.tellg() - position );
    file_.seekg( position, std::ios_base::beg );
    break;

  default: // Should be a MIDI channel event
    if ( c & 0x80 ) { // MIDI status byte
      if ( c > 0xF0 ) goto error;
      trackStatus_[track] = c;
      event->push_back( c );
      c &= 0xF0;
      if ( (c == 0xC0) || (c == 0xD0) ) bytes = 1;
      else bytes = 2;
    }
    else if ( trackStatus_[track] & 0x80 ) { // Running status
      event->push_back( trackStatus_[track] );
      event->push_back( c );
      c = trackStatus_[track] & 0xF0;
      if ( (c != 0xC0) && (c != 0xD0) ) bytes = 1;
    }
    else goto error;

  }

  // Read the rest of the event into the event vector.
  unsigned long i;
  for ( i=0; i<bytes; i++ ) {
    if ( !file_.read( (char *)&c, 1 ) ) goto error;
    event->push_back( c );
  }

  if ( !usingTimeCode_ ) {
    if ( isTempoEvent ) {
      // Parse the tempo event and update tickSeconds_[track].
      double tickrate = (double) (division_ & 0x7FFF);
      unsigned long value = ( event->at(3) << 16 ) + ( event->at(4) << 8 ) + event->at(5);
      tickSeconds_[track] = (double) (0.000001 * value / tickrate);
    }

    if ( format_ == 1 ) {
      // Update track counter and check the tempo map.
      trackCounters_[track] += ticks;
      TempoChange tempoEvent = tempoEvents_[ trackTempoIndex_[track] ];
      if ( trackCounters_[track] >= tempoEvent.count && trackTempoIndex_[track] < tempoEvents_.size() - 1 ) {
        trackTempoIndex_[track]++;
        tickSeconds_[track] = tempoEvent.tickSeconds;
      }
    }
  }

  // Save the current track pointer value.
  trackPointers_[track] = (long)file_.tellg();

  return ticks;

 error:
  oStream_ << "MidiFileIn::getNextEvent: file read error!";
  handleError( StkError::FILE_ERROR );
  return 0;
}

unsigned long MidiFileIn :: getNextMidiEvent( std::vector<unsigned char> *midiEvent, unsigned int track )
{
  // Fill the user-provided vector with the next MIDI event in the
  // specified track (default = 0) and return the event delta time in
  // ticks.  Meta-Events preceeding this event are skipped and ignored.
  if ( track >= nTracks_ ) {
    oStream_ << "MidiFileIn::getNextMidiEvent: invalid track argument (" <<  track << ").";
    handleError( StkError::WARNING ); return 0;
  }

  unsigned long ticks = getNextEvent( midiEvent, track );
  while ( midiEvent->size() && ( midiEvent->at(0) >= 0xF0 ) ) {
    //for ( unsigned int i=0; i<midiEvent->size(); i++ )
      //std::cout << "event byte = " << i << ", value = " << (int)midiEvent->at(i) << std::endl;
    ticks = getNextEvent( midiEvent, track );
  }

  //for ( unsigned int i=0; i<midiEvent->size(); i++ )
    //std::cout << "event byte = " << i << ", value = " << (int)midiEvent->at(i) << std::endl;

  return ticks;
}

bool MidiFileIn :: readVariableLength( unsigned long *value )
{
  // It is assumed that this function is called with the file read
  // pointer positioned at the start of a variable-length value.  The
  // function returns "true" if the value is successfully parsed and
  // "false" otherwise.
  *value = 0;
  char c;

  if ( !file_.read( &c, 1 ) ) return false;
  *value = (unsigned long) c;
  if ( *value & 0x80 ) {
    *value &= 0x7f;
    do {
      if ( !file_.read( &c, 1 ) ) return false;
      *value = ( *value << 7 ) + ( c & 0x7f );
    } while ( c & 0x80 );
  }

  return true;
} 

} // stk namespace
