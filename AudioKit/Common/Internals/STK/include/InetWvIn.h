#ifndef STK_INETWVIN_H
#define STK_INETWVIN_H

#include "WvIn.h"
#include "TcpServer.h"
#include "UdpSocket.h"
#include "Thread.h"
#include "Mutex.h"

namespace stk {

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

typedef struct {
  bool finished;
  void *object;
} ThreadInfo;

class InetWvIn : public WvIn
{
public:
  //! Default constructor.
  /*!
    An StkError will be thrown if an error occurs while initializing the input thread.
  */
  InetWvIn( unsigned long bufferFrames = 1024, unsigned int nBuffers = 8 );

  //! Class destructor.
  ~InetWvIn();

  //! Wait for a (new) socket connection with specified protocol, port, data channels and format.
  /*!
    For the UDP protocol, this function will create a socket
    instance and return.  For the TCP protocol, this function will
    block until a connection is established.  An StkError will be
    thrown if a socket error occurs or an invalid function argument is
    provided.
  */
  void listen( int port = 2006, unsigned int nChannels = 1,
               Stk::StkFormat format = STK_SINT16,
               Socket::ProtocolType protocol = Socket::PROTO_TCP );

  //! Returns true is an input connection exists or input data remains in the queue.
  /*!
    This method will not return false after an input connection has been closed until
    all buffered input data has been read out.
  */
  bool isConnected( void );

  //! Return the specified channel value of the last computed frame.
  /*!
    For multi-channel files, use the lastFrame() function to get
    all values from the last computed frame.  If no connection exists,
    the returned value is 0.0.  The \c channel argument must be less
    than the number of channels in the data stream (the first channel
    is specified by 0).  However, range checking is only performed if
    _STK_DEBUG_ is defined during compilation, in which case an
    out-of-range value will trigger an StkError exception.
  */
  StkFloat lastOut( unsigned int channel = 0 );

  //! Compute a sample frame and return the specified \c channel value.
  /*!
    For multi-channel files, use the lastFrame() function to get
    all values from the computed frame.  If no connection exists, the
    returned value is 0.0 (and a warning will be issued if _STK_DEBUG_
    is defined during compilation).  The \c channel argument must be
    less than the number of channels in the data stream (the first
    channel is specified by 0).  However, range checking is only
    performed if _STK_DEBUG_ is defined during compilation, in which
    case an out-of-range value will trigger an StkError exception.
  */
  StkFloat tick( unsigned int channel = 0 );

  //! Fill the StkFrames object with computed sample frames, starting at the specified channel and return the same reference.
  /*!
    The \c channel argument plus the number of channels specified
    in the listen() function must be less than the number of channels
    in the StkFrames argument (the first channel is specified by 0).
    However, this is only checked if _STK_DEBUG_ is defined during
    compilation, in which case an incompatibility will trigger an
    StkError exception.  If no connection exists, the function does
    nothing (a warning will be issued if _STK_DEBUG_ is defined during
    compilation).
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  // Called by the thread routine to receive data via the socket connection
  // and fill the socket buffer.  This is not intended for general use but
  // must be public for access from the thread.
  void receive( void );

protected:

  // Read buffered socket data into the data buffer ... will block if none available.
  int readData( void );

  Socket *soket_;
  Thread thread_;
  Mutex mutex_;
  char *buffer_;
  unsigned long bufferFrames_;
  unsigned long bufferBytes_;
  unsigned long bytesFilled_;
  unsigned int nBuffers_;
  unsigned long writePoint_;
  unsigned long readPoint_;
  long bufferCounter_;
  int dataBytes_;
  bool connected_;
  int fd_;
  ThreadInfo threadInfo_;
  Stk::StkFormat dataType_;

};

inline StkFloat InetWvIn :: lastOut( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= data_.channels() ) {
    oStream_ << "InetWvIn::lastOut(): channel argument and data stream are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  // If no connection and we've output all samples in the queue, return.
  if ( !connected_ && bytesFilled_ == 0 && bufferCounter_ == 0 ) return 0.0;

  return lastFrame_[channel];
}

} // stk namespace

#endif
