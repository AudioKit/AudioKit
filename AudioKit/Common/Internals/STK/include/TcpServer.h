#ifndef STK_TCPSERVER_H
#define STK_TCPSERVER_H

#include "Socket.h"

namespace stk {

/***************************************************/
/*! \class TcpServer
    \brief STK TCP socket server class.

    This class provides a uniform cross-platform TCP socket server
    interface.  Methods are provided for reading or writing data
    buffers to/from connections.

    TCP sockets are reliable and connection-oriented.  A TCP socket
    server must accept a connection from a TCP client before data can
    be sent or received.  Data delivery is guaranteed in order,
    without loss, error, or duplication.  That said, TCP transmissions
    tend to be slower than those using the UDP protocol and data sent
    with multiple \e write() calls can be arbitrarily combined by the
    underlying system.

    The user is responsible for checking the values
    returned by the read/write methods.  Values
    less than or equal to zero indicate a closed
    or lost connection or the occurence of an error.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class TcpServer : public Socket
{
 public:
  //! Default constructor creates a local socket server on port 2006 (or the specified port number).
  /*!
    An StkError will be thrown if a socket error occurs during instantiation.
  */
  TcpServer( int port = 2006 );

  //! The class destructor closes the socket instance, breaking any existing connections.
  ~TcpServer();

  //! Extract the first pending connection request from the queue and create a new connection, returning the descriptor for the accepted socket.
  /*!
    If no connection requests are pending and the socket has not
    been set non-blocking, this function will block until a connection
    is present.  If an error occurs, -1 is returned.
  */
  int accept( void );

  //! Write a buffer over the socket connection.  Returns the number of bytes written or -1 if an error occurs.
  int writeBuffer(const void *buffer, long bufferSize, int flags = 0);

  //! Read a buffer from the socket connection, up to length \e bufferSize.  Returns the number of bytes read or -1 if an error occurs.
  int readBuffer(void *buffer, long bufferSize, int flags = 0);

 protected:

};

} // stk namespace

#endif
