#ifndef STK_THREAD_H
#define STK_THREAD_H

#include "Stk.h"

#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))

  #include <pthread.h>
  #define THREAD_TYPE
  typedef pthread_t THREAD_HANDLE;
  typedef void * THREAD_RETURN;
  typedef void * (*THREAD_FUNCTION)(void *);

#elif defined(__OS_WINDOWS__)

  #include <windows.h>
  #include <process.h>
  #define THREAD_TYPE __stdcall
  typedef unsigned long THREAD_HANDLE;
  typedef unsigned THREAD_RETURN;
  typedef unsigned (__stdcall *THREAD_FUNCTION)(void *);

#endif

namespace stk {

/***************************************************/
/*! \class Thread
    \brief STK thread class.

    This class provides a uniform interface for cross-platform
    threads.  On unix systems, the pthread library is used.  Under
    Windows, the C runtime threadex functions are used.

    Each instance of the Thread class can be used to control a single
    thread process.  Routines are provided to signal cancelation
    and/or joining with a thread, though it is not possible for this
    class to know the running status of a thread once it is started.

    For cross-platform compatability, thread functions should be
    declared as follows:

    THREAD_RETURN THREAD_TYPE thread_function(void *ptr)

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Thread : public Stk
{
 public:
  //! Default constructor.
  Thread();

  //! The class destructor does not attempt to cancel or join a thread.
  ~Thread();

  //! Begin execution of the thread \e routine.  Upon success, true is returned.
  /*!
    A data pointer can be supplied to the thread routine via the
    optional \e ptr argument.  If the thread cannot be created, the
    return value is false.
  */
  bool start( THREAD_FUNCTION routine, void * ptr = NULL );

  //! Signal cancellation of a thread routine, returning \e true on success.
  /*!
    This function only signals thread cancellation.  It does not
    wait to verify actual routine termination.  A \e true return value
    only signifies that the cancellation signal was properly executed,
    not thread cancellation.  A thread routine may need to make use of
    the testCancel() function to specify a cancellation point.
  */
  bool cancel(void);

  //! Block the calling routine indefinitely until the thread terminates.
  /*!
    This function suspends execution of the calling routine until the thread has terminated.  It will return immediately if the thread was already terminated.  A \e true return value signifies successful termination.  A \e false return value indicates a problem with the wait call.
  */
  bool wait(void);

  //! Create a cancellation point within a thread routine.
  /*!
    This function call checks for thread cancellation, allowing the
    thread to be terminated if a cancellation request was previously
    signaled.
  */
  void testCancel(void);

 protected:

  THREAD_HANDLE thread_;

};

} // stk namespace

#endif
