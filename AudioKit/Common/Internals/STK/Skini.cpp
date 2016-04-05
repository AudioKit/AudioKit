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

    noteOn  60.01  111.132

    See also SKINI.txt.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Skini.h"
#include "SKINItbl.h"
#include <cstdlib>
#include <sstream>

namespace stk {

Skini :: Skini()
{
}

Skini :: ~Skini()
{
}

bool Skini :: setFile( std::string fileName )
{
  if ( file_.is_open() ) {
    oStream_ << "Skini::setFile: already reaading a file!";
    handleError( StkError::WARNING );
    return false;
  }

  file_.open( fileName.c_str() );
  if ( !file_ ) {
    oStream_ << "Skini::setFile: unable to open file (" << fileName << ")";
    handleError( StkError::WARNING );
    return false;
  }

  return true;
}

long Skini :: nextMessage( Message& message )
{
  if ( !file_.is_open() ) return 0;

  std::string line;
  bool done = false;
  while ( !done ) {

    // Read a line from the file and skip over invalid messages.
    if ( std::getline( file_, line ).eof() ) {
      oStream_ << "// End of Score.  Thanks for using SKINI!!";
      handleError( StkError::STATUS );
      file_.close();
      message.type = 0;
      done = true;
    }
    else if ( parseString( line, message ) > 0 ) done = true;
  }

  return message.type;  
}

void Skini :: tokenize( const std::string&        str,
                        std::vector<std::string>& tokens,
                        const std::string&        delimiters )
{
  // Skip delimiters at beginning.
  std::string::size_type lastPos = str.find_first_not_of(delimiters, 0);
  // Find first "non-delimiter".
  std::string::size_type pos     = str.find_first_of(delimiters, lastPos);

  while (std::string::npos != pos || std::string::npos != lastPos) {
    // Found a token, add it to the vector.
    tokens.push_back(str.substr(lastPos, pos - lastPos));
    // Skip delimiters.  Note the "not_of"
    lastPos = str.find_first_not_of(delimiters, pos);
    // Find next "non-delimiter"
    pos = str.find_first_of(delimiters, lastPos);
  }
} 

long Skini :: parseString( std::string& line, Message& message )
{
  message.type = 0;
  if ( line.empty() ) return message.type;

  // Check for comment lines.
  std::string::size_type lastPos = line.find_first_not_of(" ,\t", 0);
  std::string::size_type pos     = line.find_first_of("/", lastPos);
  if ( std::string::npos != pos ) {
    oStream_ << "// Comment Line: " << line;
    handleError( StkError::STATUS );
    return message.type;
  }

  // Tokenize the string.
  std::vector<std::string> tokens; 
  this->tokenize( line, tokens, " ,\t");

  // Valid SKINI messages must have at least three fields (type, time,
  // and channel).
  if ( tokens.size() < 3 ) return message.type;

  // Determine message type.
  int iSkini = 0;
  while ( iSkini < __SK_MaxMsgTypes_ ) {
    if ( tokens[0] == skini_msgs[iSkini].messageString ) break;
    iSkini++;
  }

  if ( iSkini >= __SK_MaxMsgTypes_ )  {
    oStream_ << "Skini::parseString: couldn't parse this line:\n   " << line;
    handleError( StkError::WARNING );
    return message.type;
  }
  
  // Found the type.
  message.type = skini_msgs[iSkini].type;

  // Parse time field.
  if ( tokens[1][0] == '=' ) {
    tokens[1].erase( tokens[1].begin() );
    if ( tokens[1].empty() ) {
      oStream_ << "Skini::parseString: couldn't parse time field in line:\n   " << line;
      handleError( StkError::WARNING );
      return message.type = 0;
    }
    message.time = (StkFloat) -atof( tokens[1].c_str() );
  }
  else
    message.time = (StkFloat) atof( tokens[1].c_str() );

  // Parse the channel field.
  message.channel = atoi( tokens[2].c_str() );

  // Parse the remaining fields (maximum of 2 more).
  int iValue = 0;
  long dataType = skini_msgs[iSkini].data2;
  while ( dataType != NOPE ) {

    if ( tokens.size() <= (unsigned int) (iValue+3) ) {
      oStream_ <<  "Skini::parseString: inconsistency between type table and parsed line:\n   " << line;
      handleError( StkError::WARNING );
      return message.type = 0;
    }

    switch ( dataType ) {

    case SK_INT:
      message.intValues[iValue] = atoi( tokens[iValue+3].c_str() );
      message.floatValues[iValue] = (StkFloat) message.intValues[iValue];
      break;

    case SK_DBL:
      message.floatValues[iValue] = atof( tokens[iValue+3].c_str() );
      message.intValues[iValue] = (long) message.floatValues[iValue];
      break;

    case SK_STR: // Must be the last field.
      message.remainder = tokens[iValue+3];
      return message.type;

    default: // MIDI extension message
      message.intValues[iValue] = dataType;
      message.floatValues[iValue] = (StkFloat) message.intValues[iValue];
      iValue--;
    }

    if ( ++iValue == 1 )
      dataType = skini_msgs[iSkini].data3;
    else
      dataType = NOPE;
  }

  return message.type;
}

std::string Skini :: whatsThisType(long type)
{
  std::string typeString;

  for ( int i=0; i<__SK_MaxMsgTypes_; i++ ) {
    if ( type == skini_msgs[i].type ) {
      typeString = skini_msgs[i].messageString;
      break;
    }
  }
  return typeString;
}

std::string Skini :: whatsThisController( long number )
{
  std::string controller;

  for ( int i=0; i<__SK_MaxMsgTypes_; i++) {
    if ( skini_msgs[i].type == __SK_ControlChange_ &&
         number == skini_msgs[i].data2) {
      controller = skini_msgs[i].messageString;
      break;
    }
  }
  return controller;
}

} // stk namespace
