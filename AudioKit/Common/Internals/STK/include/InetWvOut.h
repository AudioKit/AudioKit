#ifndef STK_INETWVOUT_H
#define STK_INETWVOUT_H

#include "WvOut.h"
#include "Socket.h"

namespace stk {

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

class InetWvOut : public WvOut
{
 public:
  //! Default constructor ... the socket is not instantiated.
  InetWvOut( unsigned long packetFrames = 1024 );

  //! Overloaded constructor which opens a network connection during instantiation.
  /*!
    An StkError is thrown if a socket error occurs or an invalid argument is specified.
  */
  InetWvOut( int port, Socket::ProtocolType protocol = Socket::PROTO_TCP,
             std::string hostname = "localhost", unsigned int nChannels = 1, Stk::StkFormat format = STK_SINT16,
             unsigned long packetFrames = 1024 );

  //! Class destructor.
  ~InetWvOut();

  //! Connect to the specified host and port and prepare to stream \e nChannels of data in the given data format.
  /*!
    An StkError is thrown if a socket error occurs or an invalid argument is specified.
  */
  void connect( int port, Socket::ProtocolType protocol = Socket::PROTO_TCP,
                std::string hostname = "localhost", unsigned int nChannels = 1, Stk::StkFormat format = STK_SINT16 );

  //! If a connection is open, write out remaining samples in the queue and then disconnect.
  void disconnect( void );

  //! Output a single sample to all channels in a sample frame.
  /*!
    An StkError is thrown if an output error occurs.  If a socket
    connection does not exist, the function does nothing (a warning
    will be issued if _STK_DEBUG_ is defined during compilation).
  */
  void tick( const StkFloat sample );

  //! Output the StkFrames data.
  /*!
    An StkError will be thrown if an output error occurs.  An
    StkError will also be thrown if _STK_DEBUG_ is defined during
    compilation and there is an incompatability between the number of
    channels in the FileWvOut object and that in the StkFrames object.
    If a socket connection does not exist, the function does nothing
    (a warning will be issued if _STK_DEBUG_ is defined during
    compilation).
  */
  void tick( const StkFrames& frames );

 protected:

  void incrementFrame( void );

  // Write a buffer of length frames via the socket connection.
  void writeData( unsigned long frames );

  char *buffer_;
  Socket *soket_;
  unsigned long bufferFrames_;
  unsigned long bufferBytes_;
  unsigned long bufferIndex_;
  unsigned long iData_;
  unsigned int dataBytes_;
  Stk::StkFormat dataType_;
};

} // stk namespace

#endif
