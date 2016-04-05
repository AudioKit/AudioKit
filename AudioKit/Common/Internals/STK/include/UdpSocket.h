#ifndef STK_UDPSOCKET_H
#define STK_UDPSOCKET_H

#include "Socket.h"

namespace stk {

/***************************************************/
/*! \class UdpSocket
    \brief STK UDP socket server/client class.

    This class provides a uniform cross-platform UDP socket
    server/client interface.  Methods are provided for reading or
    writing data buffers.  The constructor creates a UDP socket and
    binds it to the specified port.  Note that only one socket can be
    bound to a given port on the same machine.

    UDP sockets provide unreliable, connection-less service.  Messages
    can be lost, duplicated, or received out of order.  That said,
    data transmission tends to be faster than with TCP connections and
    datagrams are not potentially combined by the underlying system.

    The user is responsible for checking the values returned by the
    read/write methods.  Values less than or equal to zero indicate
    the occurence of an error.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class UdpSocket : public Socket
{
 public:
  //! Default constructor creates a local UDP socket on port 2006 (or the specified port number).
  /*!
    An StkError will be thrown if a socket error occurs during instantiation.
  */
  UdpSocket( int port = 2006 );

  //! The class destructor closes the socket instance.
  ~UdpSocket();

  //! Set the address for subsequent outgoing data sent via the \e writeBuffer() function.
  /*!
    An StkError will be thrown if the host is unknown.
  */
  void setDestination( int port = 2006, std::string hostname = "localhost" );

  //! Send a buffer to the address specified with the \e setDestination() function.  Returns the number of bytes written or -1 if an error occurs.
  /*!
    This function will fail if the default address (set with \e setDestination()) is invalid or has not been specified.
   */
  int writeBuffer(const void *buffer, long bufferSize, int flags = 0);

  //! Read an input buffer, up to length \e bufferSize.  Returns the number of bytes read or -1 if an error occurs.
  int readBuffer(void *buffer, long bufferSize, int flags = 0);

  //! Write a buffer to the specified socket.  Returns the number of bytes written or -1 if an error occurs.
  int writeBufferTo(const void *buffer, long bufferSize, int port, std::string hostname = "localhost", int flags = 0 );

 protected:

  //! A protected function for use in writing a socket address structure.
  /*!
    An StkError will be thrown if the host is unknown.
  */
  void setAddress( struct sockaddr_in *address, int port = 2006, std::string hostname = "localhost" );

  struct sockaddr_in address_;
  bool validAddress_;

};

} // stk namespace

#endif
