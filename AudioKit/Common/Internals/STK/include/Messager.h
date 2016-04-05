#ifndef STK_MESSAGER_H
#define STK_MESSAGER_H

#include "Stk.h"
#include "Skini.h"
#include <queue>

#if defined(__STK_REALTIME__)

#include "Mutex.h"
#include "Thread.h"
#include "TcpServer.h"
#include "RtMidi.h"

#endif // __STK_REALTIME__

namespace stk {

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

const int DEFAULT_QUEUE_LIMIT = 200;

class Messager : public Stk
{
 public:

  // This structure is used to share data among the various realtime
  // messager threads.  It must be public.
  struct MessagerData {
    Skini skini;
    std::queue<Skini::Message> queue;
    unsigned int queueLimit;
    int sources;

#if defined(__STK_REALTIME__)
    Mutex mutex;
    RtMidiIn *midi;
    TcpServer *socket;
    std::vector<int> fd;
    fd_set mask;
#endif

    // Default constructor.
    MessagerData()
      :queueLimit(0), sources(0) {}
  };

  //! Default constructor.
  Messager();

  //! Class destructor.
  ~Messager();

  //! Pop the next message from the queue and write it to the referenced message structure.
  /*!
    Invalid messages (or an empty queue) are indicated by type
    values of zero, in which case all other message structure values
    are undefined.  The user MUST verify the returned message type is
    valid before reading other message values.
  */
  void popMessage( Skini::Message& message );

  //! Push the referenced message onto the message stack.
  void pushMessage( Skini::Message& message );

  //! Specify a SKINI formatted scorefile from which messages should be read.
  /*!
    A return value of \c true indicates the call was successful.  A
    return value of \c false can occur if the file is not found,
    cannot be opened, another file is currently still open, or if a
    realtime input mechanism is running.  Scorefile input is
    considered to be a non-realtime control mechanism that cannot run
    concurrently with realtime input.
  */
  bool setScoreFile( const char* filename );

#if defined(__STK_REALTIME__)
  //! Initiate the "realtime" retreival from stdin of control messages into the queue.
  /*!
    This function initiates a thread for asynchronous retrieval of
    SKINI formatted messages from stdin.  A return value of \c true
    indicates the call was successful.  A return value of \c false can
    occur if a scorefile is being read, a stdin thread is already
    running, or a thread error occurs during startup.  Stdin input is
    considered to be a realtime control mechanism that cannot run
    concurrently with non-realtime scorefile input.
  */
  bool startStdInput();

  //! Start a socket server, accept connections, and read "realtime" control messages into the message queue.
  /*!
    This function creates a socket server on the optional port
    (default = 2001) and starts a thread for asynchronous retrieval of
    SKINI formatted messages from socket connections.  A return value
    of \c true indicates the call was successful.  A return value of
    \c false can occur if a scorefile is being read, a socket thread
    is already running, or an error occurs during the socket server
    or thread initialization stages.  Socket input is considered to be
    a realtime control mechanism that cannot run concurrently with
    non-realtime scorefile input.
  */
  bool startSocketInput( int port=2001 );

  //! Start MIDI input, with optional device and port identifiers.
  /*!
    This function creates an RtMidiIn instance for MIDI input.  The
    RtMidiIn class invokes a local callback function to read incoming
    messages into the queue.  If \c port = -1, RtMidiIn will open a
    virtual port to which other software applications can connect (OS
    X and Linux only).  A return value of \c true indicates the call
    was successful.  A return value of \c false can occur if a
    scorefile is being read, MIDI input is already running, or an
    error occurs during RtMidiIn construction.  Midi input is
    considered to be a realtime control mechanism that cannot run
    concurrently with non-realtime scorefile input.
  */
  bool startMidiInput( int port=0 );

#endif

 protected:

  MessagerData data_;

#if defined(__STK_REALTIME__)
  Thread stdinThread_;
  Thread socketThread_;
#endif

};

} // stk namespace

#endif
