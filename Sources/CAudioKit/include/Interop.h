// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#ifdef __OBJC__
#define AK_SWIFT_TYPE __attribute((swift_newtype(struct)))
#else
#define AK_SWIFT_TYPE
#endif

/// Pointer to an instance of an DSPBase subclass
#ifndef __cplusplus
typedef void* DSPRef AK_SWIFT_TYPE;
#else
typedef class DSPBase* DSPRef;
#endif

#ifdef __cplusplus
#define AK_API extern "C"
#else
#define AK_API
#endif
