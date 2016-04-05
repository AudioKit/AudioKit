/***************************************************/
/*! \class InetWvOut
    \brief STK internet streaming output class.

    This WvOut subclass can stream data over a network via a TCP or
    UDP socket connection.  The data is converted to big-endian byte
    order, if necessary, before being transmitted.

    InetWvOut supports multi-channel data.  It is important to
    distinguish the tick() method that outputs a single sample to all
    channels in a sample frame from the overloaded one that takes a
    reference to an StkFrames object for multi-channel and/or
    multi-frame data.

    This class connects to a socket server, the port and IP address of
    which must be specified as constructor arguments.  The default
    data type is signed 16-bit integers but any of the defined
    StkFormats are permissible.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "InetWvOut.h"
#include "TcpClient.h"
#include "UdpSocket.h"
#include <sstream>

namespace stk {

InetWvOut :: InetWvOut( unsigned long packetFrames )
  : buffer_(0), soket_(0), bufferFrames_(packetFrames), bufferBytes_(0)
{
}

InetWvOut :: InetWvOut( int port, Socket::ProtocolType protocol, std::string hostname,
                        unsigned int nChannels, Stk::StkFormat format, unsigned long packetFrames )
  : buffer_(0), soket_(0), bufferFrames_(packetFrames), bufferBytes_(0)
{
  connect( port, protocol, hostname, nChannels, format );
}

InetWvOut :: ~InetWvOut()
{
  disconnect();
  if ( soket_ ) delete soket_;
  if ( buffer_ ) delete [] buffer_;
}

void InetWvOut :: connect( int port, Socket::ProtocolType protocol, std::string hostname,
                           unsigned int nChannels, Stk::StkFormat format )
{
  if ( soket_ && soket_->isValid( soket_->id() ) )
    disconnect();

  if ( nChannels == 0 ) {
    oStream_ << "InetWvOut::connect: the channel argument must be greater than zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  if ( format == STK_SINT8 ) dataBytes_ = 1;
  else if ( format == STK_SINT16 ) dataBytes_ = 2;
  else if ( format == STK_SINT32 || format == STK_FLOAT32 ) dataBytes_ = 4;
  else if ( format == STK_FLOAT64 ) dataBytes_ = 8;
  else {
    oStream_ << "InetWvOut::connect: unknown data type specified.";
    handleError( StkError::FUNCTION_ARGUMENT );
  } 
  dataType_ = format;

  if ( protocol == Socket::PROTO_TCP ) {
    soket_ = new TcpClient( port, hostname );
  }
  else {
    // For UDP sockets, the sending and receiving sockets cannot have
    // the same port number.  Since the port argument corresponds to
    // the destination port, we will associate this socket instance
    // with a different port number (arbitrarily determined as port -
    // 1).
    UdpSocket *socket = new UdpSocket( port - 1 );
    socket->setDestination( port, hostname );
    soket_ = (Socket *) socket;
  }

  // Allocate new memory if necessary.
  data_.resize( bufferFrames_, nChannels );
  unsigned long bufferBytes = dataBytes_ * bufferFrames_ * nChannels;
  if ( bufferBytes > bufferBytes_ ) {
    if ( buffer_) delete [] buffer_;
    buffer_ = (char *) new char[ bufferBytes ];
    bufferBytes_ = bufferBytes;
  }
  frameCounter_ = 0;
  bufferIndex_ = 0;
  iData_ = 0;
}

void InetWvOut :: disconnect(void)
{
  if ( soket_ ) {
    writeData( bufferIndex_ );
    soket_->close( soket_->id() );
    delete soket_;
    soket_ = 0;
  }
}

void InetWvOut :: writeData( unsigned long frames )
{
  unsigned long samples = frames * data_.channels();
  if ( dataType_ == STK_SINT8 ) {
    signed char *ptr = (signed char *) buffer_;
    for ( unsigned long k=0; k<samples; k++ ) {
      this->clipTest( data_[k] );
      *ptr++ = (signed char) (data_[k] * 127.0);
    }
  }
  else if ( dataType_ == STK_SINT16 ) {
    SINT16 *ptr = (SINT16 *) buffer_;
    for ( unsigned long k=0; k<samples; k++ ) {
      this->clipTest( data_[k] );
      *ptr = (SINT16) (data_[k] * 32767.0);
#ifdef __LITTLE_ENDIAN__
      swap16 ((unsigned char *)ptr);
#endif
      ptr++;
    }
  }
  else if ( dataType_ == STK_SINT32 ) {
    SINT32 *ptr = (SINT32 *) buffer_;
    for ( unsigned long k=0; k<samples; k++ ) {
      this->clipTest( data_[k] );
      *ptr = (SINT32) (data_[k] * 2147483647.0);
#ifdef __LITTLE_ENDIAN__
      swap32 ((unsigned char *)ptr);
#endif
      ptr++;
    }
  }
  else if ( dataType_ == STK_FLOAT32 ) {
    FLOAT32 *ptr = (FLOAT32 *) buffer_;
    for ( unsigned long k=0; k<samples; k++ ) {
      this->clipTest( data_[k] );
      *ptr = (FLOAT32) data_[k];
#ifdef __LITTLE_ENDIAN__
      swap32 ((unsigned char *)ptr);
#endif
      ptr++;
    }
  }
  else if ( dataType_ == STK_FLOAT64 ) {
    FLOAT64 *ptr = (FLOAT64 *) buffer_;
    for ( unsigned long k=0; k<samples; k++ ) {
      this->clipTest( data_[k] );
      *ptr = (FLOAT64) data_[k];
#ifdef __LITTLE_ENDIAN__
      swap64 ((unsigned char *)ptr);
#endif
      ptr++;
    }
  }

  long bytes = dataBytes_ * samples;
  if ( soket_->writeBuffer( (const void *)buffer_, bytes, 0 ) < 0 ) {
    oStream_ << "InetWvOut: connection to socket server failed!";
    handleError( StkError::PROCESS_SOCKET );
  }
}

void InetWvOut :: incrementFrame( void )
{
  frameCounter_++;
  bufferIndex_++;

  if ( bufferIndex_ == bufferFrames_ ) {
    writeData( bufferFrames_ );
    bufferIndex_ = 0;
    iData_ = 0;
  }
}

void InetWvOut :: tick( const StkFloat sample )
{
  if ( !soket_ || !soket_->isValid( soket_->id() ) ) {
#if defined(_STK_DEBUG_)
    oStream_ << "InetWvOut::tick(): a valid socket connection does not exist!";
    handleError( StkError::DEBUG_PRINT );
#endif
    return;
  }

  unsigned int nChannels = data_.channels();
  StkFloat input = sample;
  clipTest( input );
  for ( unsigned int j=0; j<nChannels; j++ )
    data_[iData_++] = input;

  this->incrementFrame();
}

void InetWvOut :: tick( const StkFrames& frames )
{
  if ( !soket_ || !soket_->isValid( soket_->id() ) ) {
#if defined(_STK_DEBUG_)
    oStream_ << "InetWvOut::tick(): a valid socket connection does not exist!";
    handleError( StkError::DEBUG_PRINT );
#endif
    return;
  }

#if defined(_STK_DEBUG_)
  if ( data_.channels() != frames.channels() ) {
    oStream_ << "InetWvOut::tick(): incompatible channel value in StkFrames argument!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  unsigned int j, nChannels = data_.channels();
  unsigned int iFrames = 0;
  for ( unsigned int i=0; i<frames.frames(); i++ ) {

    for ( j=0; j<nChannels; j++ ) {
      data_[iData_] = frames[iFrames++];
      clipTest( data_[iData_++] );
    }

    this->incrementFrame();
  }
}

} // stk namespace
