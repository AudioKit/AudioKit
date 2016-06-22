#ifndef STK_SKINI_H
#define STK_SKINI_H

#include "Stk.h"
#include <vector>
#include <string>
#include <fstream>

namespace stk {

/***************************************************/
/*! \class Skini
    \brief STK SKINI parsing class

    This class parses SKINI formatted text
    messages.  It can be used to parse individual
    messages or it can be passed an entire file.
    The SKINI specification is Perry's and his
    alone, but it's all text so it shouldn't be too
    hard to figure out.

    SKINI (Synthesis toolKit Instrument Network
    Interface) is like MIDI, but allows for
    floating-point control changes, note numbers,
    etc.  The following example causes a sharp
    middle C to be played with a velocity of 111.132:

    \code
    noteOn  60.01  111.132
    \endcode

    \sa \ref skini

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Skini : public Stk
{
 public:

  //! A message structure to store and pass parsed SKINI messages.
  struct Message { 
    long type;                         /*!< The message type, as defined in SKINImsg.h. */
    long channel;                      /*!< The message channel (not limited to 16!). */
    StkFloat time;                     /*!< The message time stamp in seconds (delta or absolute). */
    std::vector<StkFloat> floatValues; /*!< The message values read as floats (values are type-specific). */
    std::vector<long> intValues;       /*!< The message values read as ints (number and values are type-specific). */
    std::string remainder;             /*!< Any remaining message data, read as ascii text. */

    // Default constructor.
    Message()
      :type(0), channel(0), time(0.0), floatValues(2), intValues(2) {}
  };

  //! Default constructor.
  Skini();

  //! Class destructor
  ~Skini();

  //! Set a SKINI formatted file for reading.
  /*!
    If the file is successfully opened, this function returns \e
    true.  Otherwise, \e false is returned.
   */
  bool setFile( std::string fileName );

  //! Parse the next file message (if a file is loaded) and return the message type.
  /*!
    This function skips over lines in a file which cannot be
    parsed.  A type value equal to zero in the referenced message
    structure (and the returned value) indicates the file end is
    reached or no file is open for reading.
  */
  long nextMessage( Skini::Message& message );

  //! Attempt to parse the given string and returning the message type.
  /*!
    A type value equal to zero in the referenced message structure
    indicates an invalid message.
  */
  long parseString( std::string& line, Skini::Message& message );

  //! Return the SKINI type string for the given type value.
  static std::string whatsThisType(long type);

  //! Return the SKINI controller string for the given controller number.
  static std::string whatsThisController(long number);

 protected:

  void tokenize( const std::string& str, std::vector<std::string>& tokens, const std::string& delimiters );

  std::ifstream file_;
};

//! A static table of equal-tempered MIDI to frequency (Hz) values.
static const double Midi2Pitch[129] = {
  8.176, 8.662, 9.177, 9.723, 10.301, 10.913, 11.562, 12.25,
  12.978, 13.75, 14.568, 15.434, 16.352, 17.324, 18.354, 19.445,
  20.602, 21.827, 23.125, 24.50, 25.957, 27.50, 29.135, 30.868,
  32.703, 34.648, 36.708, 38.891, 41.203, 43.654, 46.249, 49.0,
  51.913, 55.0, 58.271, 61.735, 65.406, 69.296, 73.416, 77.782,
  82.407, 87.307, 92.499, 97.999, 103.826, 110.0, 116.541, 123.471,
  130.813, 138.591, 146.832, 155.563, 164.814, 174.614, 184.997, 195.998,
  207.652, 220.0, 233.082, 246.942, 261.626, 277.183, 293.665, 311.127,
  329.628, 349.228, 369.994, 391.995, 415.305, 440.0, 466.164, 493.883,
  523.251, 554.365, 587.33, 622.254, 659.255, 698.456, 739.989, 783.991,
  830.609, 880.0, 932.328, 987.767, 1046.502, 1108.731, 1174.659, 1244.508,
  1318.51, 1396.913, 1479.978, 1567.982, 1661.219, 1760.0, 1864.655, 1975.533,
  2093.005, 2217.461, 2349.318, 2489.016, 2637.02, 2793.826, 2959.955, 3135.963,
  3322.438, 3520.0, 3729.31, 3951.066, 4186.009, 4434.922, 4698.636, 4978.032,
  5274.041, 5587.652, 5919.911, 6271.927, 6644.875, 7040.0, 7458.62, 7902.133,
  8372.018, 8869.844, 9397.273, 9956.063, 10548.082, 11175.303, 11839.822, 12543.854,
  13289.75};

} // stk namespace

#endif


