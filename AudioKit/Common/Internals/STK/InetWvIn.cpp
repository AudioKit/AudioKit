/***************************************************/
/*! \class InetWvIn
    \brief STK internet streaming input class.

    This Wvin subclass reads streamed audio data over a network via a
    TCP or UDP socket connection.  The data is assumed in big-endian,
    or network, byte order.  Only a single socket connection is
    supported.

    InetWvIn supports multi-channel data.  It is important to
    distinguish the tick() method that computes a single frame (and
    returns only the specified sample of a multi-channel frame) from
    the overloaded one that takes an StkFrames object for
    multi-channel and/or multi-frame data.

    This class implements a socket server.  When using the TCP
    protocol, the server "listens" for a single remote connection
    within the InetWvIn::start() function.  For the UDP protocol, no
    attempt is made to verify packet delivery or order.  The default
    data type for the incoming stream is signed 16-bit integers,
    though any of the defined StkFormats are permissible.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "InetWvIn.h"
#include <sstream>

namespace stk {

extern "C" THREAD_RETURN THREAD_TYPE inputThread( void * ptr )
{
  ThreadInfo *info = (ThreadInfo *)ptr;

  while ( !info->finished ) {
    ((InetWvIn *) info->object)->receive();
  }

  return 0;
}

InetWvIn :: InetWvIn( unsigned long bufferFrames, unsigned int nBuffers )
  :soket_(0), buffer_(0), bufferFrames_(bufferFrames), bufferBytes_(0), nBuffers_(nBuffers), connected_(false)
{
  threadInfo_.finished = false;
  threadInfo_.object = (void *) this;

  // Start the input thread.
  if ( !thread_.start( &inputThread, &threadInfo_ ) ) {
    oStream_ << "InetWvIn(): unable to start input thread in constructor!";
    handleError( StkError::PROCESS_THREAD );
  }
}

InetWvIn :: ~InetWvIn()
{
  // Close down the thread.
  connected_ = false;
  threadInfo_.finished = true;

  if ( soket_ ) delete soket_;
  if ( buffer_ ) delete [] buffer_;
}

void InetWvIn :: listen( int port, unsigned int nChannels,
                         Stk::StkFormat format, Socket::ProtocolType protocol )
{
  mutex_.lock();

  if ( connected_ ) delete soket_;

  if ( nChannels < 1 ) {
    oStream_ << "InetWvIn()::listen(): the channel argument must be greater than zero.";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  if ( format == STK_SINT16 ) dataBytes_ = 2;
  else if ( format == STK_SINT32 || format == STK_FLOAT32 ) dataBytes_ = 4;
  else if ( format == STK_FLOAT64 ) dataBytes_ = 8;
  else if ( format == STK_SINT8 ) dataBytes_ = 1;
  else {
    oStream_ << "InetWvIn(): unknown data type specified!";
    handleError( StkError::FUNCTION_ARGUMENT );
  } 
  dataType_ = format;

  unsigned long bufferBytes = bufferFrames_ * nBuffers_ * nChannels * dataBytes_;
  if ( bufferBytes > bufferBytes_ ) {
    if ( buffer_) delete [] buffer_;
    buffer_ = (char *) new char[ bufferBytes ];
    bufferBytes_ = bufferBytes;
  }

  data_.resize( bufferFrames_, nChannels );
  lastFrame_.resize( 1, nChannels, 0.0 );

  bufferCounter_ = 0;
  writePoint_ = 0;
  readPoint_ = 0;
  bytesFilled_ = 0;

  if ( protocol == Socket::PROTO_TCP ) {
    TcpServer *socket = new TcpServer( port );
    oStream_ << "InetWvIn:listen(): waiting for TCP connection on port " << socket->port() << " ... ";
    handleError( StkError::STATUS );
    fd_ = socket->accept();
    if ( fd_ < 0) {
      oStream_ << "InetWvIn::listen(): Error accepting TCP connection request!";
      handleError( StkError::PROCESS_SOCKET );
    }
    oStream_ << "InetWvIn::listen(): TCP socket connection made!";
    handleError( StkError::STATUS );
    soket_ = (Socket *) socket;
  }
  else {
    soket_ = new UdpSocket( port );
    fd_ = soket_->id();
  }

  connected_ = true;

  mutex_.unlock();
}

void InetWvIn :: receive( void )
{
  if ( !connected_ ) {
    Stk::sleep(100);
    return;
  }

  fd_set mask;
  FD_ZERO( &mask );
  FD_SET( fd_, &mask );

  // The select function will block until data is available for reading.
  select( fd_+1, &mask, (fd_set *)0, (fd_set *)0, NULL );

  if ( FD_ISSET( fd_, &mask ) ) {
    mutex_.lock();
    unsigned long unfilled = bufferBytes_ - bytesFilled_;
    if ( unfilled > 0 ) {
      // There's room in our buffer for more data.
      unsigned long endPoint = writePoint_ + unfilled;
      if ( endPoint > bufferBytes_ ) unfilled -= endPoint - bufferBytes_;
      int i = soket_->readBuffer( fd_, (void *)&buffer_[writePoint_], unfilled, 0 );
      //int i = Socket::readBuffer( fd_, (void *)&buffer_[writePoint_], unfilled, 0 );
      if ( i <= 0 ) {
        oStream_ << "InetWvIn::receive(): the remote InetWvIn socket has closed.";
        handleError( StkError::STATUS );
        connected_ = false;
        mutex_.unlock();
        return;
      }
      bytesFilled_ += i;
      writePoint_ += i;
      if ( writePoint_ == bufferBytes_ )
        writePoint_ = 0;
      mutex_.unlock();
    }
    else {
      // Sleep 10 milliseconds AFTER unlocking mutex.
      mutex_.unlock();
      Stk::sleep( 10 );
    }
  }
}

int InetWvIn :: readData( void )
{
  // We have two potential courses of action should this method
  // be called and the input buffer isn't sufficiently filled.
  // One solution is to fill the data buffer with zeros and return.
  // The other solution is to wait until the necessary data exists.
  // I chose the latter, as it works for both streamed files
  // (non-realtime data transport) and realtime playback (given
  // adequate network bandwidth and speed).

  // Wait until data is ready.
  unsigned long bytes = data_.size() * dataBytes_;
  while ( connected_ && bytesFilled_ < bytes )
    Stk::sleep( 10 );

  if ( !connected_ && bytesFilled_ == 0 ) return 0;
  bytes = ( bytesFilled_ < bytes ) ? bytesFilled_ : bytes;

  // Copy samples from buffer to data.
  StkFloat gain;
  long samples = bytes / dataBytes_;
  mutex_.lock();
  if ( dataType_ == STK_SINT16 ) {
    gain = 1.0 / 32767.0;
    SINT16 *buf = (SINT16 *) (buffer_+readPoint_);
    for (int i=0; i<samples; i++ ) {
#ifdef __LITTLE_ENDIAN__
      swap16((unsigned char *) buf);
#endif
      data_[i] = (StkFloat) *buf++;
      data_[i] *= gain;
    }
  }
  else if ( dataType_ == STK_SINT32 ) {
    gain = 1.0 / 2147483647.0;
    SINT32 *buf = (SINT32 *) (buffer_+readPoint_);
    for (int i=0; i<samples; i++ ) {
#ifdef __LITTLE_ENDIAN__
      swap32((unsigned char *) buf);
#endif
      data_[i] = (StkFloat) *buf++;
      data_[i] *= gain;
    }
  }
  else if ( dataType_ == STK_FLOAT32 ) {
    FLOAT32 *buf = (FLOAT32 *) (buffer_+readPoint_);
    for (int i=0; i<samples; i++ ) {
#ifdef __LITTLE_ENDIAN__
      swap32((unsigned char *) buf);
#endif
      data_[i] = (StkFloat) *buf++;
    }
  }
  else if ( dataType_ == STK_FLOAT64 ) {
    FLOAT64 *buf = (FLOAT64 *) (buffer_+readPoint_);
    for (int i=0; i<samples; i++ ) {
#ifdef __LITTLE_ENDIAN__
      swap64((unsigned char *) buf);
#endif
      data_[i] = (StkFloat) *buf++;
    }
  }
  else if ( dataType_ == STK_SINT8 ) {
    gain = 1.0 / 127.0;
    signed char *buf = (signed char *) (buffer_+readPoint_);
    for (int i=0; i<samples; i++ ) {
      data_[i] = (StkFloat) *buf++;
      data_[i] *= gain;
    }
  }

  readPoint_ += bytes;
  if ( readPoint_ == bufferBytes_ )
    readPoint_ = 0;
  bytesFilled_ -= bytes;

  mutex_.unlock();
  return samples / data_.channels();
}

bool InetWvIn :: isConnected( void )
{
  if ( bytesFilled_ > 0 || bufferCounter_ > 0 )
    return true;
  else
    return connected_;
}

StkFloat InetWvIn :: tick( unsigned int channel )
{
  // If no connection and we've output all samples in the queue, return 0.0.
  if ( !connected_ && bytesFilled_ == 0 && bufferCounter_ == 0 ) {
#if defined(_STK_DEBUG_)
    oStream_ << "InetWvIn::tick(): a valid socket connection does not exist!";
    handleError( StkError::DEBUG_PRINT );
#endif
    return 0.0;
  }

#if defined(_STK_DEBUG_)
  if ( channel >= data_.channels() ) {
    oStream_ << "InetWvIn::tick(): channel argument is incompatible with data stream!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  if ( bufferCounter_ == 0 )
    bufferCounter_ = readData();

  unsigned int nChannels = lastFrame_.channels();
  long index = ( bufferFrames_ - bufferCounter_ ) * nChannels;
  for ( unsigned int i=0; i<nChannels; i++ )
    lastFrame_[i] = data_[index++];

  bufferCounter_--;
  if ( bufferCounter_ < 0 )
    bufferCounter_ = 0;

  return lastFrame_[channel];
}

StkFrames& InetWvIn :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - data_.channels() ) {
    oStream_ << "InetWvIn::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  // If no connection and we've output all samples in the queue, return.
  if ( !connected_ && bytesFilled_ == 0 && bufferCounter_ == 0 ) {
#if defined(_STK_DEBUG_)
    oStream_ << "InetWvIn::tick(): a valid socket connection does not exist!";
    handleError( StkError::DEBUG_PRINT );
#endif
    return frames;
  }

  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - data_.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    this->tick();
    for ( j=0; j<lastFrame_.channels(); j++ )
      *samples++ = lastFrame_[j];
  }

  return frames;
}

} // stk namespace
