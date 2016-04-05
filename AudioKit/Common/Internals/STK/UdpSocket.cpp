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

#include "UdpSocket.h"
#include <cstring>
#include <sstream>

namespace stk {

UdpSocket :: UdpSocket(int port )
{
  validAddress_ = false;

#if defined(__OS_WINDOWS__)  // windoze-only stuff
  WSADATA wsaData;
  WORD wVersionRequested = MAKEWORD(1,1);

  WSAStartup(wVersionRequested, &wsaData);
  if (wsaData.wVersion != wVersionRequested) {
    oStream_ << "UdpSocket: Incompatible Windows socket library version!";
    handleError( StkError::PROCESS_SOCKET );
  }
#endif

  // Create the UDP socket
  soket_ = ::socket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
  if ( soket_ < 0 ) {
    oStream_ << "UdpSocket: Couldn't create UDP socket!";
    handleError( StkError::PROCESS_SOCKET );
  }

  struct sockaddr_in address;
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = INADDR_ANY;
  address.sin_port = htons( port );

  // Bind socket to the appropriate port and interface (INADDR_ANY)
  if ( bind(soket_, (struct sockaddr *)&address, sizeof(address)) < 0 ) {
    oStream_ << "UdpSocket: Couldn't bind socket in constructor!";
    handleError( StkError::PROCESS_SOCKET );
  }

  port_ = port;
}

UdpSocket :: ~UdpSocket()
{
}

void UdpSocket :: setDestination( int port, std::string hostname )
{
  this->setAddress( &address_, port, hostname );
  validAddress_ = true;
}

void UdpSocket :: setAddress( struct sockaddr_in *address, int port, std::string hostname )
{
  struct hostent *hostp;
  if ( (hostp = gethostbyname( hostname.c_str() )) == 0 ) {
    oStream_ << "UdpSocket::setAddress: unknown host (" << hostname << ")!";
    handleError( StkError::PROCESS_SOCKET_IPADDR );
  }

  // Fill in the address structure
  address->sin_family = AF_INET;
  memcpy((void *)&address->sin_addr, hostp->h_addr, hostp->h_length);
  address->sin_port = htons( port );
}

int UdpSocket :: writeBuffer( const void *buffer, long bufferSize, int flags )
{
  if ( !isValid( soket_ ) || !validAddress_ ) return -1;
  return sendto( soket_, (const char *)buffer, bufferSize, flags, (struct sockaddr *)&address_, sizeof(address_) );
}

int UdpSocket :: readBuffer( void *buffer, long bufferSize, int flags )
{
  if ( !isValid( soket_ ) ) return -1;
  return recvfrom( soket_, (char *)buffer, bufferSize, flags, NULL, NULL );
}

int UdpSocket :: writeBufferTo( const void *buffer, long bufferSize, int port, std::string hostname, int flags )
{
  if ( !isValid( soket_ ) ) return -1;
  struct sockaddr_in address;
  this->setAddress( &address, port, hostname );
  return sendto( soket_, (const char *)buffer, bufferSize, flags, (struct sockaddr *)&address, sizeof(address) );
}

} // stk namespace
