/*
Copyright (C) 2016 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Part of Core Audio Public Utility Classes
*/

#ifndef __CAXException_h__
#define __CAXException_h__

#if !defined(__COREAUDIO_USE_FLAT_INCLUDES__)
	#include <CoreFoundation/CoreFoundation.h>
#else
	#include <ConditionalMacros.h>
	#include <CoreFoundation.h>
#endif
#include "CADebugMacros.h"
#include <ctype.h>
//#include <stdio.h>
#include <string.h>


class CAX4CCString {
public:
	CAX4CCString(OSStatus error) {
		// see if it appears to be a 4-char-code
		UInt32 beErr = CFSwapInt32HostToBig(error);
		char *str = mStr;
		memcpy(str + 1, &beErr, 4);
		if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
			str[0] = str[5] = '\'';
			str[6] = '\0';
		} else if (error > -200000 && error < 200000)
			// no, format it as an integer
			snprintf(str, sizeof(mStr), "%d", (int)error);
		else
			snprintf(str, sizeof(mStr), "0x%x", (int)error);
	}
	const char *get() const { return mStr; }
	operator const char *() const { return mStr; }
private:
	char mStr[16];
};

class CAX4CCStringNoQuote {
public:
	CAX4CCStringNoQuote(OSStatus error) {
		// see if it appears to be a 4-char-code
		UInt32 beErr = CFSwapInt32HostToBig(error);
		char *str = mStr;
		memcpy(str, &beErr, 4);
		if (isprint(str[0]) && isprint(str[1]) && isprint(str[2]) && isprint(str[3])) {
			str[4] = '\0';
		} else if (error > -200000 && error < 200000)
			// no, format it as an integer
			snprintf(str, sizeof(mStr), "%d", (int)error);
		else
			snprintf(str, sizeof(mStr), "0x%x", (int)error);
	}
	const char *get() const { return mStr; }
	operator const char *() const { return mStr; }
private:
	char mStr[16];
};


// An extended exception class that includes the name of the failed operation
class CAXException {
public:
	CAXException(const char *operation, OSStatus err) :
		mError(err)
		{
			if (operation == NULL)
				mOperation[0] = '\0';
			else if (strlen(operation) >= sizeof(mOperation)) {
				memcpy(mOperation, operation, sizeof(mOperation) - 1);
				mOperation[sizeof(mOperation) - 1] = '\0';
			} else

			strlcpy(mOperation, operation, sizeof(mOperation));
		}
	
	char *FormatError(char *str, size_t strsize) const
	{
		return FormatError(str, strsize, mError);
	}
	
	char				mOperation[256];
	const OSStatus		mError;
	
	// -------------------------------------------------
	
	typedef void (*WarningHandler)(const char *msg, OSStatus err);
	
	static char *FormatError(char *str, size_t strsize, OSStatus error)
	{
		strlcpy(str, CAX4CCString(error), strsize);
		return str;
	}
	
	static void Warning(const char *s, OSStatus error)
	{
		if (sWarningHandler)
			(*sWarningHandler)(s, error);
	}
	
	static void SetWarningHandler(WarningHandler f) { sWarningHandler = f; }
private:
	static WarningHandler	sWarningHandler;
};

#if	DEBUG || CoreAudio_Debug
	#define XThrowIfError(error, operation)										\
		do {																	\
			OSStatus __err = error;												\
			if (__err) {														\
				DebugMessageN4("%s:%d: about to throw %s: %s", __FILE__, __LINE__, CAX4CCString(__err).get(), operation);\
				__THROW_STOP;															\
				throw CAXException(operation, __err);							\
			}																	\
		} while (0)

	#define XThrowIf(condition, error, operation)								\
		do {																	\
			if (condition) {													\
				OSStatus __err = error;											\
				DebugMessageN4("%s:%d: about to throw %s: %s", __FILE__, __LINE__, CAX4CCString(__err).get(), operation);\
				__THROW_STOP;															\
				throw CAXException(operation, __err);							\
			}																	\
		} while (0)

	#define XRequireNoError(error, label)										\
		do {																	\
			OSStatus __err = error;												\
			if (__err) {														\
				DebugMessageN4("%s:%d: about to throw %s: %s", __FILE__, __LINE__, CAX4CCString(__err).get(), #error);\
				STOP;															\
				goto label;														\
			}																	\
		} while (0)
	
	#define XAssert(assertion)													\
		do {																	\
			if (!(assertion)) {													\
				DebugMessageN3("%s:%d: error: failed assertion: %s", __FILE__, __LINE__, #assertion);		\
				__ASSERT_STOP;															\
			}																	\
		} while (0)
	
	#define XAssertNoError(error)												\
		do {																	\
			OSStatus __err = error;												\
			if (__err) {														\
				DebugMessageN4("%s:%d: error %s: %s", __FILE__, __LINE__, CAX4CCString(__err).get(), #error);\
				__ASSERT_STOP;															\
			}																	\
		} while (0)

	#define ca_require_noerr(errorCode, exceptionLabel)							\
		do																		\
		{																		\
			int evalOnceErrorCode = (errorCode);								\
			if ( __builtin_expect(0 != evalOnceErrorCode, 0) )					\
			{																	\
				DebugMessageN5("ca_require_noerr: [%s, %d] (goto %s;) %s:%d",	\
					#errorCode,	evalOnceErrorCode,		 						\
					#exceptionLabel,											\
					__FILE__,													\
					__LINE__);													\
				goto exceptionLabel;											\
			}																	\
		} while ( 0 )

	#define ca_verify_noerr(errorCode)											\
		do																		\
		{																		\
			int evalOnceErrorCode = (errorCode);								\
			if ( __builtin_expect(0 != evalOnceErrorCode, 0) )					\
			{																	\
				DebugMessageN4("ca_verify_noerr: [%s, %d] %s:%d",				\
					#errorCode,	evalOnceErrorCode,								\
					__FILE__,													\
					__LINE__);													\
			}																	\
		} while ( 0 )

	#define ca_debug_string(message)											\
		do																		\
		{																		\
			DebugMessageN3("ca_debug_string: %s %s:%d",							\
				message,														\
				__FILE__,														\
				__LINE__);														\
		} while ( 0 )


	#define ca_verify(assertion)												\
		do																		\
		{																		\
			if ( __builtin_expect(!(assertion), 0) )							\
			{																	\
				DebugMessageN3("ca_verify: %s %s:%d",							\
					#assertion,													\
					__FILE__,													\
					__LINE__);													\
			}																	\
		} while ( 0 )

	#define ca_require(assertion, exceptionLabel)								\
		do																		\
		{																		\
			if ( __builtin_expect(!(assertion), 0) )							\
			{																	\
				DebugMessageN4("ca_require: %s %s %s:%d",						\
					#assertion,													\
					#exceptionLabel,											\
					__FILE__,													\
					__LINE__);													\
				goto exceptionLabel;											\
			}																	\
		} while ( 0 )

   #define ca_check(assertion)													\
      do																		\
      {																			\
          if ( __builtin_expect(!(assertion), 0) )								\
          {																		\
              DebugMessageN3("ca_check: %s %s:%d",							\
                  #assertion,													\
                  __FILE__,														\
                  __LINE__);													\
          }																		\
      } while ( 0 )
		
#else
	#define XThrowIfError(error, operation)										\
		do {																	\
			OSStatus __err = error;												\
			if (__err) {														\
				throw CAXException(operation, __err);							\
			}																	\
		} while (0)

	#define XThrowIf(condition, error, operation)								\
		do {																	\
			if (condition) {													\
				OSStatus __err = error;											\
				throw CAXException(operation, __err);							\
			}																	\
		} while (0)

	#define XRequireNoError(error, label)										\
		do {																	\
			OSStatus __err = error;												\
			if (__err) {														\
				goto label;														\
			}																	\
		} while (0)

	#define XAssert(assertion)													\
		do {																	\
			if (!(assertion)) {													\
			}																	\
		} while (0)

	#define XAssertNoError(error)												\
		do {																	\
			/*OSStatus __err =*/ error;											\
		} while (0)

	#define ca_require_noerr(errorCode, exceptionLabel)							\
		do																		\
		{																		\
			if ( __builtin_expect(0 != (errorCode), 0) )						\
			{																	\
				goto exceptionLabel;											\
			}																	\
		} while ( 0 )

	#define ca_verify_noerr(errorCode)											\
		do																		\
		{																		\
			if ( 0 != (errorCode) )												\
			{																	\
			}																	\
		} while ( 0 )

	#define ca_debug_string(message)

	#define ca_verify(assertion)												\
		do																		\
		{																		\
			if ( !(assertion) )													\
			{																	\
			}																	\
		} while ( 0 )

	#define ca_require(assertion, exceptionLabel)								\
		do																		\
		{																		\
			if ( __builtin_expect(!(assertion), 0) )							\
			{																	\
				goto exceptionLabel;											\
			}																	\
		} while ( 0 )

   #define ca_check(assertion)													\
		do																		\
		{																		\
			if ( !(assertion) )													\
			{																	\
			}																	\
		} while ( 0 )


#endif

#define XThrow(error, operation) XThrowIf(true, error, operation)
#define XThrowIfErr(error) XThrowIfError(error, #error)

#endif // __CAXException_h__
