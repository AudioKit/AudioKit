// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#ifdef __OBJC__
#define AK_ENUM(a) enum __attribute__((enum_extensibility(open))) a : int
#define AK_SWIFT_TYPE __attribute((swift_newtype(struct)))
#else
#define AK_ENUM(a) enum a
#define AK_SWIFT_TYPE
#endif

/* EXAMPLE

 Define enum in ObjC/C/C++:
 typedef AK_ENUM(Direction){
     DirectionUp,
     DirectionRight,
     DirectionDown,
     DirectionLeft,
 }AKDirection;

 Then use in Swift:
 let direction: Direction = .up
*/

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
