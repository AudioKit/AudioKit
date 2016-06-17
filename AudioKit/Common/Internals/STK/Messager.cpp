/***************************************************/
/*! \class Messager
    \brief STK input control message parser.

    This class reads and parses control messages from a variety of
    sources, such as a scorefile, MIDI port, socket connection, or
    stdin.  MIDI messages are retrieved using the RtMidi class.  All
    other input sources (scorefile, socket, or stdin) are assumed to
    provide SKINI formatted messages.  This class can be compiled with
    generic, non-realtime support, in which case only scorefile
    reading is possible.

    The various \e realtime message acquisition mechanisms (from MIDI,
    socket, or stdin) take place asynchronously, filling the message
    queue.  A call to popMessage() will pop the next available control
    message from the queue and return it via the referenced Message
    structure.  When a \e non-realtime scorefile is set, it is not
    possible to start reading realtime input messages (from MIDI,
    socket, or stdin).  Likewise, it is not possible to read from a
    scorefile when a realtime input mechanism is running.

    When MIDI input is started, input is also automatically read from
    stdin.  This allows for program termination via the terminal
    window.  An __SK_Exit_ message is pushed onto the stack whenever
    an "exit" or "Exit" message is received from stdin or when all
    socket connections close and no stdin thread is running.

    This class is primarily for use in STK example programs but it is
    generic enough to work in many other contexts.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Messager.h"
#include <iostream>
#include <algorithm>
#include "SKINImsg.h"

namespace stk {

#if defined(__STK_REALTIME__)

extern "C" THREAD_RETURN THREAD_TYPE stdinHandler(void * ptr);
extern "C" THREAD_RETURN THREAD_TYPE socketHandler(void * ptr);

#endif // __STK_REALTIME__

typedef int MessagerSourceType;
MessagerSourceType STK_FILE   = 0x1;
MessagerSourceType STK_MIDI   = 0x2;
MessagerSourceType STK_STDIN   = 0x4;
MessagerSourceType STK_SOCKET = 0x8;

Messager :: Messager()
{
  data_.sources = 0;
  data_.queueLimit = DEFAULT_QUEUE_LIMIT;
#if defined(__STK_REALTIME__)
  data_.socket = 0;
  data_.midi = 0;
#endif
}

Messager :: ~Messager()
{
  // Clear the queue in case any thread is waiting on its limit.
#if defined(__STK_REALTIME__)
  data_.mutex.lock();
#endif
  while ( data_.queue.size() ) data_.queue.pop();
  data_.sources = 0;

#if defined(__STK_REALTIME__)
  data_.mutex.unlock();
  if ( data_.socket ) {
    socketThread_.wait();
    delete data_.socket;
  }

  if ( data_.midi ) delete data_.midi;
#endif
}

bool Messager :: setScoreFile( const char* filename )
{
  if ( data_.sources ) {
    if ( data_.sources == STK_FILE ) {
      oStream_ << "Messager::setScoreFile: already reading a scorefile!";
      handleError( StkError::WARNING );
    }
    else {
      oStream_ << "Messager::setScoreFile: already reading realtime control input ... cannot do scorefile input too!";
      handleError( StkError::WARNING );
    }
    return false;
  }

  if ( !data_.skini.setFile( filename ) ) return false;
  data_.sources = STK_FILE;
  return true;
}

void Messager :: popMessage( Skini::Message& message )
{
  if ( data_.sources == STK_FILE ) { // scorefile input
    if ( !data_.skini.nextMessage( message ) )
      message.type = __SK_Exit_;
    return;
  }

  if ( data_.queue.size() == 0 ) {
    // An empty (or invalid) message is indicated by a type = 0.
    message.type = 0;
    return;
  }

  // Copy queued message to the message pointer structure and then "pop" it.
#if defined(__STK_REALTIME__)
  data_.mutex.lock();
#endif
  message = data_.queue.front();
  data_.queue.pop();
#if defined(__STK_REALTIME__)
  data_.mutex.unlock();
#endif
}

void Messager :: pushMessage( Skini::Message& message )
{
#if defined(__STK_REALTIME__)
  data_.mutex.lock();
#endif
  data_.queue.push( message );
#if defined(__STK_REALTIME__)
  data_.mutex.unlock();
#endif
}

#if defined(__STK_REALTIME__)

bool Messager :: startStdInput()
{
  if ( data_.sources == STK_FILE ) {
    oStream_ << "Messager::startStdInput: already reading a scorefile ... cannot do realtime control input too!";
    handleError( StkError::WARNING );
    return false;
  }

  if ( data_.sources & STK_STDIN ) {
    oStream_ << "Messager::startStdInput: stdin input thread already started.";
    handleError( StkError::WARNING );
    return false;
  }

  // Start the stdin input thread.
  if ( !stdinThread_.start( (THREAD_FUNCTION)&stdinHandler, &data_ ) ) {
    oStream_ << "Messager::startStdInput: unable to start stdin input thread!";
    handleError( StkError::WARNING );
    return false;
  }
  data_.sources |= STK_STDIN;
  return true;
}

THREAD_RETURN THREAD_TYPE stdinHandler(void *ptr)
{
  Messager::MessagerData *data = (Messager::MessagerData *) ptr;
  Skini::Message message;

  std::string line;
  while ( !std::getline( std::cin, line).eof() ) {
    if ( line.empty() ) continue;
    if ( line.compare(0, 4, "Exit") == 0 || line.compare(0, 4, "exit") == 0 )
      break;

    data->mutex.lock();
    if ( data->skini.parseString( line, message ) )
      data->queue.push( message );
    data->mutex.unlock();

    while ( data->queue.size() >= data->queueLimit ) Stk::sleep( 50 );
  }

  // We assume here that if someone types an "exit" message in the
  // terminal window, all processing should stop.
  message.type = __SK_Exit_;
  data->queue.push( message );
  data->sources &= ~STK_STDIN;

  return NULL;
}

void midiHandler( double timeStamp, std::vector<unsigned char> *bytes, void *ptr )
{
  if ( bytes->size() < 2 ) return;

  // Parse the MIDI bytes ... only keep MIDI channel messages.
  if ( bytes->at(0) > 239 ) return;

  Messager::MessagerData *data = (Messager::MessagerData *) ptr;
  Skini::Message message;

  message.type = bytes->at(0) & 0xF0;
  message.channel = bytes->at(0) & 0x0F;
  message.time = 0.0; // realtime messages should have delta time = 0.0
  message.intValues[0] = bytes->at(1);
  message.floatValues[0] = (StkFloat) message.intValues[0];
  if ( ( message.type != 0xC0 ) && ( message.type != 0xD0 ) ) {
    if ( bytes->size() < 3 ) return;
    message.intValues[1] = bytes->at(2);
    if ( message.type == 0xE0 ) { // combine pithbend into single "14-bit" value
      message.intValues[0] += message.intValues[1] <<= 7;
      message.floatValues[0] = (StkFloat) message.intValues[0];
      message.intValues[1] = 0;
    }
    else
      message.floatValues[1] = (StkFloat) message.intValues[1];
  }

  while ( data->queue.size() >= data->queueLimit ) Stk::sleep( 50 );

  data->mutex.lock();
  data->queue.push( message );
  data->mutex.unlock();
}

bool Messager :: startMidiInput( int port )
{
  if ( data_.sources == STK_FILE ) {
    oStream_ << "Messager::startMidiInput: already reading a scorefile ... cannot do realtime control input too!";
    handleError( StkError::WARNING );
    return false;
  }

  if ( data_.sources & STK_MIDI ) {
    oStream_ << "Messager::startMidiInput: MIDI input already started.";
    handleError( StkError::WARNING );
    return false;
  }

  // First start the stdin input thread if it isn't already running
  // (to allow the user to exit).
  if ( !( data_.sources & STK_STDIN ) ) {
    if ( this->startStdInput() == false ) {
      oStream_ << "Messager::startMidiInput: unable to start input from stdin.";
      handleError( StkError::WARNING );
      return false;
    }
  }

  try {
    data_.midi = new RtMidiIn();
    data_.midi->setCallback( &midiHandler, (void *) &data_ );
    if ( port == -1 ) data_.midi->openVirtualPort();
    else data_.midi->openPort( (unsigned int)port );
  }
  catch ( RtMidiError &error ) {
    oStream_ << "Messager::startMidiInput: error creating RtMidiIn instance (" << error.getMessage() << ").";
    handleError( StkError::WARNING );
    return false;
  }

  data_.sources |= STK_MIDI;
  return true;
}

bool Messager :: startSocketInput( int port )
{
  if ( data_.sources == STK_FILE ) {
    oStream_ << "Messager::startSocketInput: already reading a scorefile ... cannot do realtime control input too!";
    handleError( StkError::WARNING );
    return false;
  }

  if ( data_.sources & STK_SOCKET ) {
    oStream_ << "Messager::startSocketInput: socket input thread already started.";
    handleError( StkError::WARNING );
    return false;
  }

  // Create the socket server.
  try {
    data_.socket = new TcpServer( port );
  }
  catch ( StkError& ) {
    return false;
  }

  oStream_ << "Socket server listening for connection(s) on port " << port << "...";
  handleError( StkError::STATUS );

  // Initialize socket descriptor information.
  FD_ZERO(&data_.mask);
  int fd = data_.socket->id();
  FD_SET( fd, &data_.mask );
  data_.fd.push_back( fd );

  // Start the socket thread.
  if ( !socketThread_.start( (THREAD_FUNCTION)&socketHandler, &data_ ) ) {
    oStream_ << "Messager::startSocketInput: unable to start socket input thread!";
    handleError( StkError::WARNING );
    return false;
  }

  data_.sources |= STK_SOCKET;
  return true;
}

#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))
  #include <sys/time.h>
  #include <errno.h>
#endif

THREAD_RETURN THREAD_TYPE socketHandler(void *ptr)
{
  Messager::MessagerData *data = (Messager::MessagerData *) ptr;
  Skini::Message message;
  std::vector<int>& fd = data->fd;

  struct timeval timeout;
  fd_set rmask;
  int newfd;
  unsigned int i;
  const int bufferSize = 1024;
  char buffer[bufferSize];
  int index = 0, bytesRead = 0;
  std::string line;
  std::vector<int> fdclose;

  while ( data->sources & STK_SOCKET ) {

    // Use select function to periodically poll socket desriptors.
    rmask = data->mask;
    timeout.tv_sec = 0; timeout.tv_usec = 50000; // 50 milliseconds
    if ( select( fd.back()+1, &rmask, (fd_set *)0, (fd_set *)0, &timeout ) <= 0 ) continue;

    // A file descriptor is set.  Check if there's a new socket connection available.
    if ( FD_ISSET( data->socket->id(), &rmask ) ) {

      // Accept and service new connection.
      newfd = data->socket->accept();
      if ( newfd >= 0 ) {
        std::cout << "New socket connection made.\n" << std::endl;

        // Set the socket to non-blocking mode.
        Socket::setBlocking( newfd, false );

        // Save the descriptor and update the masks.
        fd.push_back( newfd );
        std::sort( fd.begin(), data->fd.end() );
        FD_SET( newfd, &data->mask );
        FD_CLR( data->socket->id(), &rmask );
      }
      else
        std::cerr << "Messager: Couldn't accept connection request!\n";
    }

    // Check the other descriptors.
    for ( i=0; i<fd.size(); i++ ) {

      if ( !FD_ISSET( fd[i], &rmask ) ) continue;

      // This connection has data.  Read and parse it.
      bytesRead = 0;
      index = 0;
#if ( defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__) )
      errno = 0;
      while (bytesRead != -1 && errno != EAGAIN) {
#elif defined(__OS_WINDOWS__)
      while (bytesRead != SOCKET_ERROR && WSAGetLastError() != WSAEWOULDBLOCK) {
#endif

        while ( index < bytesRead ) {
          line += buffer[index];
          if ( buffer[index++] == '\n' ) {
            data->mutex.lock();
            if ( line.compare(0, 4, "Exit") == 0 || line.compare(0, 4, "exit") == 0 ) {
              // Ignore this line and assume the connection will be
              // closed on a subsequent read call.
              ;
            }
            else if ( data->skini.parseString( line, message ) )
              data->queue.push( message );
            data->mutex.unlock();
            line.erase();
          }
        }
        index = 0;

        bytesRead = Socket::readBuffer(fd[i], buffer, bufferSize, 0);
        if (bytesRead == 0) {
          // This socket connection closed.
          FD_CLR( fd[i], &data->mask );
          Socket::close( fd[i] );
          fdclose.push_back( fd[i] );
        }
      }
    }

    // Now remove descriptors for closed connections.
    for ( i=0; i<fdclose.size(); i++ ) {
      for ( unsigned int j=0; j<fd.size(); j++ ) {
        if ( fd[j] == fdclose[i] ) {
          fd.erase( fd.begin() + j );
          break;
        }
      }

      // Check to see whether all connections are closed.  Note that
      // the server descriptor will always remain.
      if ( fd.size() == 1 ) {
        data->sources &= ~STK_SOCKET;
        if ( data->sources & STK_MIDI )
          std::cout << "MIDI input still running ... type 'exit<cr>' to quit.\n" << std::endl;
        else if ( !(data->sources & STK_STDIN) ) {
          // No stdin thread running, so quit now.
          message.type = __SK_Exit_;
          data->queue.push( message );
        }
      }
      fdclose.clear();
    }

    // Wait until we're below the queue limit.
    while ( data->queue.size() >= data->queueLimit ) Stk::sleep( 50 );
  }

  return NULL;
}

#endif

} // stk namespace

