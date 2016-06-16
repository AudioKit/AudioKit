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

#include "Thread.h"

namespace stk {

Thread :: Thread()
{
  thread_ = 0;
}

Thread :: ~Thread()
{
}

bool Thread :: start( THREAD_FUNCTION routine, void * ptr )
{
  if ( thread_ ) {
    oStream_ << "Thread:: a thread is already running!";
    handleError( StkError::WARNING );
    return false;
  }

#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))

  if ( pthread_create(&thread_, NULL, *routine, ptr) == 0 )
    return true;

#elif defined(__OS_WINDOWS__)
  unsigned thread_id;
  thread_ = _beginthreadex(NULL, 0, routine, ptr, 0, &thread_id);
  if ( thread_ ) return true;

#endif
  return false;
}

bool Thread :: cancel()
{
#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))

  if ( pthread_cancel(thread_) == 0 ) {
    return true;
  }

#elif defined(__OS_WINDOWS__)

  TerminateThread((HANDLE)thread_, 0);
  return true;

#endif
  return false;
}

bool Thread :: wait()
{
#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))

  if ( pthread_join(thread_, NULL) == 0 ) {
    thread_ = 0;
    return true;
  }

#elif defined(__OS_WINDOWS__)

  long retval = WaitForSingleObject( (HANDLE)thread_, INFINITE );
  if ( retval == WAIT_OBJECT_0 ) {
    CloseHandle( (HANDLE)thread_ );
    thread_ = 0;
    return true;
  }

#endif
  return false;
}

void Thread :: testCancel(void)
{
#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))

  pthread_testcancel();

#endif
}

} // stk namespace
