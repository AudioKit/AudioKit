/***************************************************/
/*! \class TcpClient
    \brief STK TCP socket client class.

    This class provides a uniform cross-platform TCP socket client
    interface.  Methods are provided for reading or writing data
    buffers to/from connections.

    TCP sockets are reliable and connection-oriented.  A TCP socket
    client must be connected to a TCP server before data can be sent
    or received.  Data delivery is guaranteed in order, without loss,
    error, or duplication.  That said, TCP transmissions tend to be
    slower than those using the UDP protocol and data sent with
    multiple \e write() calls can be arbitrarily combined by the
    underlying system.

    The user is responsible for checking the values
    returned by the read/write methods.  Values
    less than or equal to zero indicate a closed
    or lost connection or the occurence of an error.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "TcpClient.h"
#include <cstring>
#include <sstream>

namespace stk {

TcpClient :: TcpClient( int port, std::string hostname )
{
#if defined(__OS_WINDOWS__)  // windoze-only stuff
  WSADATA wsaData;
  WORD wVersionRequested = MAKEWORD(1,1);

  WSAStartup( wVersionRequested, &wsaData );
  if ( wsaData.wVersion != wVersionRequested ) {
    oStream_ << "TcpClient: Incompatible Windows socket library version!";
    handleError( StkError::PROCESS_SOCKET );
  }
#endif

  // Create a socket client connection.
  connect( port, hostname );
}

TcpClient :: ~TcpClient( void )
{
}

int TcpClient :: connect( int port, std::string hostname )
{
  // Close any existing connections.
  this->close( soket_ );

  // Create the client-side socket
  soket_ = ::socket( AF_INET, SOCK_STREAM, IPPROTO_TCP );
  if ( soket_ < 0 ) {
    oStream_ << "TcpClient: Couldn't create socket client!";
    handleError( StkError::PROCESS_SOCKET );
  }

  int flag = 1;
  int result = setsockopt( soket_, IPPROTO_TCP, TCP_NODELAY, (char *)&flag, sizeof(int) );
  if ( result < 0 ) {
    oStream_ << "TcpClient: Error setting socket options!";
    handleError( StkError::PROCESS_SOCKET );
  }

  struct hostent *hostp;
  if ( ( hostp = gethostbyname( hostname.c_str() ) ) == 0 ) {
    oStream_ << "TcpClient: unknown host (" << hostname << ")!";
    handleError( StkError::PROCESS_SOCKET_IPADDR );
  }

  // Fill in the address structure
  struct sockaddr_in server_address;
  server_address.sin_family = AF_INET;
  memcpy( (void *)&server_address.sin_addr, hostp->h_addr, hostp->h_length );
  server_address.sin_port = htons(port);

  // Connect to the server
  if ( ::connect( soket_, (struct sockaddr *)&server_address, sizeof(server_address) ) < 0 ) {
    oStream_ << "TcpClient: Couldn't connect to socket server!";
    handleError( StkError::PROCESS_SOCKET );
  }

  return soket_;
}

int TcpClient :: writeBuffer( const void *buffer, long bufferSize, int flags )
{
  if ( !isValid( soket_ ) ) return -1;
  return send( soket_, (const char *)buffer, bufferSize, flags );
}

int TcpClient :: readBuffer( void *buffer, long bufferSize, int flags )
{
  if ( !isValid( soket_ ) ) return -1;
  return recv( soket_, (char *)buffer, bufferSize, flags );
}

} // stk namespace
