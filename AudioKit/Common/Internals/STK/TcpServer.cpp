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

#include "TcpServer.h"

namespace stk {

TcpServer :: TcpServer( int port )
{
  // Create a socket server.
#if defined(__OS_WINDOWS__)  // windoze-only stuff
  WSADATA wsaData;
  WORD wVersionRequested = MAKEWORD(1,1);

  WSAStartup(wVersionRequested, &wsaData);
  if (wsaData.wVersion != wVersionRequested) {
    oStream_ << "TcpServer: Incompatible Windows socket library version!";
    handleError( StkError::PROCESS_SOCKET );
  }
#endif

  // Create the server-side socket
  soket_ = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (soket_ < 0) {
    oStream_ << "TcpServer: Couldn't create socket server!";
    handleError( StkError::PROCESS_SOCKET );
  }

  int flag = 1;
  int result = setsockopt( soket_, IPPROTO_TCP, TCP_NODELAY, (char *)&flag, sizeof(int) );
  if (result < 0) {
    oStream_ << "TcpServer: Error setting socket options!";
    handleError( StkError::PROCESS_SOCKET );
  }

  struct sockaddr_in address;
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = INADDR_ANY;
  address.sin_port = htons( port );

  // Bind socket to the appropriate port and interface (INADDR_ANY)
  if ( bind( soket_, (struct sockaddr *)&address, sizeof(address) ) < 0 ) {
    oStream_ << "TcpServer: Couldn't bind socket!";
    handleError( StkError::PROCESS_SOCKET );
  }

  // Listen for incoming connection(s)
  if ( listen( soket_, 1 ) < 0 ) {
    oStream_ << "TcpServer: Couldn't start server listening!";
    handleError( StkError::PROCESS_SOCKET );
  }

  port_ = port;
}

TcpServer :: ~TcpServer()
{
}

int TcpServer :: accept( void )
{
  return ::accept( soket_, NULL, NULL );
}

int TcpServer :: writeBuffer(const void *buffer, long bufferSize, int flags )
{
  if ( !isValid( soket_ ) ) return -1;
  return send( soket_, (const char *)buffer, bufferSize, flags );
}

int TcpServer :: readBuffer(void *buffer, long bufferSize, int flags )
{
  if ( !isValid( soket_ ) ) return -1;
  return recv( soket_, (char *)buffer, bufferSize, flags );
}

} // stk namespace
