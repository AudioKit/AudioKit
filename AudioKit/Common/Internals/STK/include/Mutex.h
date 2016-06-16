#ifndef STK_MUTEX_H
#define STK_MUTEX_H

#include "Stk.h"

#if (defined(__OS_IRIX__) || defined(__OS_LINUX__) || defined(__OS_MACOSX__))

  #include <pthread.h>
  typedef pthread_mutex_t MUTEX;
  typedef pthread_cond_t CONDITION;

#elif defined(__OS_WINDOWS__)

  #include <windows.h>
  #include <process.h>
  typedef CRITICAL_SECTION MUTEX;
  typedef HANDLE CONDITION;

#endif

namespace stk {

/***************************************************/
/*! \class Mutex
    \brief STK mutex class.

    This class provides a uniform interface for
    cross-platform mutex use.  On Linux and IRIX
    systems, the pthread library is used. Under
    Windows, critical sections are used.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Mutex : public Stk
{
 public:
  //! Default constructor.
  Mutex();

  //! Class destructor.
  ~Mutex();

  //! Lock the mutex.
  void lock(void);

  //! Unlock the mutex.
  void unlock(void);

  //! Wait indefinitely on the mutex condition variable.
  /*!
    The mutex must be locked before calling this function, and then
    subsequently unlocked after this function returns.
   */
  void wait(void);

  //! Signal the condition variable.
  /*!
    The mutex must be locked before calling this function, and then
    subsequently unlocked after this function returns.
   */
  void signal(void);

 protected:

  MUTEX mutex_;
  CONDITION condition_;

};

} // stk namespace

#endif
