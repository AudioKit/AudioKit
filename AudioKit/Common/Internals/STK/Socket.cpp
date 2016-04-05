/***************************************************/
/*! \class Socket
    \brief STK internet socket abstract base class.

    This class provides common functionality for TCP and UDP internet
    socket server and client subclasses.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Socket.h"

namespace stk {

Socket :: Socket()
{
  soket_ = -1;
  port_ = -1;
}

Socket :: ~Socket()
{
  this->close( soket_ );

#if defined(__OS_WINDOWS__)

  WSACleanup();

#endif
}

void Socket :: close( int socket )
{
  if ( !isValid( socket ) ) return;

#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))

  ::close( socket );

#elif defined(__OS_WINDOWS__)

  ::closesocket( socket );

#endif
}

void Socket :: setBlocking( int socket, bool enable )
{
  if ( !isValid( socket ) ) return;

#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))

  int tmp = ::fcntl( socket, F_GETFL, 0 );
  if ( tmp >= 0 )
    tmp = ::fcntl( socket, F_SETFL, enable ? (tmp &~ O_NONBLOCK) : (tmp | O_NONBLOCK) );

#elif defined(__OS_WINDOWS__)

  unsigned long non_block = !enable;
  ioctlsocket( socket, FIONBIO, &non_block );

#endif
}

int Socket :: writeBuffer(int socket, const void *buffer, long bufferSize, int flags )
{
  if ( !isValid( socket ) ) return -1;
  return send( socket, (const char *)buffer, bufferSize, flags );
}

int Socket :: readBuffer(int socket, void *buffer, long bufferSize, int flags )
{
  if ( !isValid( socket ) ) return -1;
  return recv( socket, (char *)buffer, bufferSize, flags );
}

} // stk namespace
