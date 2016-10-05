/***************************************************/
/*! \class Stk
    \brief STK base class

    Nearly all STK classes inherit from this class.
    The global sample rate can be queried and
    modified via Stk.  In addition, this class
    provides error handling and byte-swapping
    functions.

    The Synthesis ToolKit in C++ (STK) is a set of open source audio
    signal processing and algorithmic synthesis classes written in the
    C++ programming language. STK was designed to facilitate rapid
    development of music synthesis and audio processing software, with
    an emphasis on cross-platform functionality, realtime control,
    ease of use, and educational example code.  STK currently runs
    with realtime support (audio and MIDI) on Linux, Macintosh OS X,
    and Windows computer platforms. Generic, non-realtime support has
    been tested under NeXTStep, Sun, and other platforms and should
    work with any standard C++ compiler.

    STK WWW site: http://ccrma.stanford.edu/software/stk/

    The Synthesis ToolKit in C++ (STK)
    Copyright (c) 1995--2016 Perry R. Cook and Gary P. Scavone

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation files
    (the "Software"), to deal in the Software without restriction,
    including without limitation the rights to use, copy, modify, merge,
    publish, distribute, sublicense, and/or sell copies of the Software,
    and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    Any person wishing to distribute modifications to the Software is
    asked to send the modifications to the original developer so that
    they can be incorporated into the canonical version.  This is,
    however, not a binding provision of this license.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
    ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
/***************************************************/

#include "Stk.h"
#include <stdlib.h>

namespace stk {

StkFloat Stk :: srate_ = (StkFloat) SRATE;
std::string Stk :: rawwavepath_ = RAWWAVE_PATH;
const Stk::StkFormat Stk :: STK_SINT8   = 0x1;
const Stk::StkFormat Stk :: STK_SINT16  = 0x2;
const Stk::StkFormat Stk :: STK_SINT24  = 0x4;
const Stk::StkFormat Stk :: STK_SINT32  = 0x8;
const Stk::StkFormat Stk :: STK_FLOAT32 = 0x10;
const Stk::StkFormat Stk :: STK_FLOAT64 = 0x20;
bool Stk :: showWarnings_ = true;
bool Stk :: printErrors_ = true;
std::vector<Stk *> Stk :: alertList_;
std::ostringstream Stk :: oStream_;

Stk :: Stk( void )
  : ignoreSampleRateChange_(false)
{
}

Stk :: ~Stk( void )
{
}

void Stk :: setSampleRate( StkFloat rate )
{
  if ( rate > 0.0 && rate != srate_ ) {
    StkFloat oldRate = srate_;
    srate_ = rate;

    for ( unsigned int i=0; i<alertList_.size(); i++ )
      alertList_[i]->sampleRateChanged( srate_, oldRate );
  }
}

void Stk :: sampleRateChanged( StkFloat /*newRate*/, StkFloat /*oldRate*/ )
{
  // This function should be reimplemented in classes that need to
  // make internal variable adjustments in response to a global sample
  // rate change.
}

void Stk :: addSampleRateAlert( Stk *ptr )
{
  for ( unsigned int i=0; i<alertList_.size(); i++ )
    if ( alertList_[i] == ptr ) return;

  alertList_.push_back( ptr );
}

void Stk :: removeSampleRateAlert( Stk *ptr )
{
  for ( unsigned int i=0; i<alertList_.size(); i++ ) {
    if ( alertList_[i] == ptr ) {
      alertList_.erase( alertList_.begin() + i );
      return;
    }
  }
}

void Stk :: setRawwavePath( std::string path )
{
  if ( !path.empty() )
    rawwavepath_ = path;

  // Make sure the path includes a "/"
  if ( rawwavepath_[rawwavepath_.length()-1] != '/' )
    rawwavepath_ += "/";
}

void Stk :: swap16(unsigned char *ptr)
{
  unsigned char val;

  // Swap 1st and 2nd bytes
  val = *(ptr);
  *(ptr) = *(ptr+1);
  *(ptr+1) = val;
}

void Stk :: swap32(unsigned char *ptr)
{
  unsigned char val;

  // Swap 1st and 4th bytes
  val = *(ptr);
  *(ptr) = *(ptr+3);
  *(ptr+3) = val;

  //Swap 2nd and 3rd bytes
  ptr += 1;
  val = *(ptr);
  *(ptr) = *(ptr+1);
  *(ptr+1) = val;
}

void Stk :: swap64(unsigned char *ptr)
{
  unsigned char val;

  // Swap 1st and 8th bytes
  val = *(ptr);
  *(ptr) = *(ptr+7);
  *(ptr+7) = val;

  // Swap 2nd and 7th bytes
  ptr += 1;
  val = *(ptr);
  *(ptr) = *(ptr+5);
  *(ptr+5) = val;

  // Swap 3rd and 6th bytes
  ptr += 1;
  val = *(ptr);
  *(ptr) = *(ptr+3);
  *(ptr+3) = val;

  // Swap 4th and 5th bytes
  ptr += 1;
  val = *(ptr);
  *(ptr) = *(ptr+1);
  *(ptr+1) = val;
}

#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))
  #include <unistd.h>
#elif defined(__OS_WINDOWS__)
  #include <windows.h>
#endif

void Stk :: sleep(unsigned long milliseconds)
{
#if defined(__OS_WINDOWS__)
  Sleep((DWORD) milliseconds);
#elif (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))
  usleep( (unsigned long) (milliseconds * 1000.0) );
#endif
}

void Stk :: handleError( StkError::Type type ) const
{
  handleError( oStream_.str(), type );
  oStream_.str( std::string() ); // reset the ostringstream buffer
}

void Stk :: handleError( const char *message, StkError::Type type )
{
  std::string msg( message );
  handleError( msg, type );
}

void Stk :: handleError( std::string message, StkError::Type type )
{
  if ( type == StkError::WARNING || type == StkError::STATUS ) {
    if ( !showWarnings_ ) return;
    std::cerr << '\n' << message << '\n' << std::endl;
  }
  else if (type == StkError::DEBUG_PRINT) {
#if defined(_STK_DEBUG_)
    std::cerr << '\n' << message << '\n' << std::endl;
#endif
  }
  else {
    if ( printErrors_ ) {
      // Print error message before throwing.
      std::cerr << '\n' << message << '\n' << std::endl;
    }
    throw StkError(message, type);
  }
}

//
// StkFrames definitions
//

StkFrames :: StkFrames( unsigned int nFrames, unsigned int nChannels )
  : data_( 0 ), nFrames_( nFrames ), nChannels_( nChannels )
{
  size_ = nFrames_ * nChannels_;
  bufferSize_ = size_;

  if ( size_ > 0 ) {
    data_ = (StkFloat *) calloc( size_, sizeof( StkFloat ) );
#if defined(_STK_DEBUG_)
    if ( data_ == NULL ) {
      std::string error = "StkFrames: memory allocation error in constructor!";
      Stk::handleError( error, StkError::MEMORY_ALLOCATION );
    }
#endif
  }

  dataRate_ = Stk::sampleRate();
}

StkFrames :: StkFrames( const StkFloat& value, unsigned int nFrames, unsigned int nChannels )
  : data_( 0 ), nFrames_( nFrames ), nChannels_( nChannels )
{
  size_ = nFrames_ * nChannels_;
  bufferSize_ = size_;
  if ( size_ > 0 ) {
    data_ = (StkFloat *) malloc( size_ * sizeof( StkFloat ) );
#if defined(_STK_DEBUG_)
    if ( data_ == NULL ) {
      std::string error = "StkFrames: memory allocation error in constructor!";
      Stk::handleError( error, StkError::MEMORY_ALLOCATION );
    }
#endif
    for ( long i=0; i<(long)size_; i++ ) data_[i] = value;
  }

  dataRate_ = Stk::sampleRate();
}

StkFrames :: ~StkFrames()
{
  if ( data_ ) free( data_ );
}

StkFrames :: StkFrames( const StkFrames& f )
  : data_(0), size_(0), bufferSize_(0)
{
  resize( f.frames(), f.channels() );
  dataRate_ = Stk::sampleRate();
  for ( unsigned int i=0; i<size_; i++ ) data_[i] = f[i];
}

StkFrames& StkFrames :: operator= ( const StkFrames& f )
{
  if ( data_ ) free( data_ );
  data_ = 0;
  size_ = 0;
  bufferSize_ = 0;
  resize( f.frames(), f.channels() );
  dataRate_ = Stk::sampleRate();
  for ( unsigned int i=0; i<size_; i++ ) data_[i] = f[i];
  return *this;
}

void StkFrames :: resize( size_t nFrames, unsigned int nChannels )
{
  nFrames_ = nFrames;
  nChannels_ = nChannels;

  size_ = nFrames_ * nChannels_;
  if ( size_ > bufferSize_ ) {
    if ( data_ ) free( data_ );
    data_ = (StkFloat *) malloc( size_ * sizeof( StkFloat ) );
#if defined(_STK_DEBUG_)
    if ( data_ == NULL ) {
      std::string error = "StkFrames::resize: memory allocation error!";
      Stk::handleError( error, StkError::MEMORY_ALLOCATION );
    }
#endif
    bufferSize_ = size_;
  }
}

void StkFrames :: resize( size_t nFrames, unsigned int nChannels, StkFloat value )
{
  this->resize( nFrames, nChannels );

  for ( size_t i=0; i<size_; i++ ) data_[i] = value;
}
    
StkFrames& StkFrames::getChannel(unsigned int sourceChannel,StkFrames& destinationFrames, unsigned int destinationChannel) const
{
#if defined(_STK_DEBUG_)
  if (sourceChannel > channels() - 1) {
    std::ostringstream error;
    error << "StkFrames::getChannel invalid sourceChannel (" << sourceChannel << ")";
    Stk::handleError( error.str(), StkError::FUNCTION_ARGUMENT);
  }
  if (destinationChannel > destinationFrames.channels() - 1) {
    std::ostringstream error;
    error << "StkFrames::getChannel invalid destinationChannel (" << destinationChannel << ")";
    Stk::handleError( error.str(), StkError::FUNCTION_ARGUMENT );
  }
  if (destinationFrames.frames() < frames()) {
    std::ostringstream error;
    error << "StkFrames::getChannel destination.frames() < frames()";
    Stk::handleError( error.str(), StkError::MEMORY_ACCESS);
  }
#endif
  int sourceHop = nChannels_;
  int destinationHop = destinationFrames.nChannels_;
  for (int i  = sourceChannel, j= destinationChannel; i < nFrames_ * nChannels_; i+=sourceHop,j+=destinationHop) {
    destinationFrames[j] = data_[i];
  }
  return destinationFrames;
        
}

void StkFrames::setChannel(unsigned int destinationChannel, const stk::StkFrames &sourceFrames,unsigned int sourceChannel)
{
#if defined(_STK_DEBUG_)
  if (sourceChannel > sourceFrames.channels() - 1) {
    std::ostringstream error;
    error << "StkFrames::setChannel invalid sourceChannel (" << sourceChannel << ")";
    Stk::handleError( error.str(), StkError::FUNCTION_ARGUMENT);
  }
  if (destinationChannel > channels() - 1) {
    std::ostringstream error;
    error << "StkFrames::setChannel invalid channel (" << destinationChannel << ")";
    Stk::handleError( error.str(), StkError::FUNCTION_ARGUMENT );
  }
  if (sourceFrames.frames() != frames()) {
    std::ostringstream error;
    error << "StkFrames::setChannel sourceFrames.frames() != frames()";
    Stk::handleError( error.str(), StkError::MEMORY_ACCESS);
  }
#endif
  unsigned int sourceHop = sourceFrames.nChannels_;
  unsigned int destinationHop = nChannels_;
  for (int i  = destinationChannel,j = sourceChannel ; i < nFrames_ * nChannels_; i+=destinationHop,j+=sourceHop) {
    data_[i] = sourceFrames[j];
  }
}

StkFloat StkFrames :: interpolate( StkFloat frame, unsigned int channel ) const
{
#if defined(_STK_DEBUG_)
  if ( frame < 0.0 || frame > (StkFloat) ( nFrames_ - 1 ) || channel >= nChannels_ ) {
    std::ostringstream error;
    error << "StkFrames::interpolate: invalid frame (" << frame << ") or channel (" << channel << ") value!";
    Stk::handleError( error.str(), StkError::MEMORY_ACCESS );
  }
#endif

  size_t iIndex = ( size_t ) frame;                    // integer part of index
  StkFloat output, alpha = frame - (StkFloat) iIndex;  // fractional part of index

  iIndex = iIndex * nChannels_ + channel;
  output = data_[ iIndex ];
  if ( alpha > 0.0 )
    output += ( alpha * ( data_[ iIndex + nChannels_ ] - output ) );

  return output;
}

} // stk namespace
