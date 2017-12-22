//
//  AKInterop.h
//  AudioKit For iOS
//
//  Created by David O'Neill on 12/22/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#ifndef AKInterop_h
#define AKInterop_h

#ifdef __OBJC__
#define AK_ENUM(a) enum __attribute__((enum_extensibility(open))) a : int
#else
#define AK_ENUM(a) enum a
#endif

/* EXAMPLE

 Define enum in ObjC/C/C++:
 typedef AK_ENUM(AKDirection){
     AKDirectionUp,
     AKDirectionRight,
     AKDirectionDown,
     AKDirectionLeft,
 }AKDirection;

 Then use in Swift:
 let direction: AKDirection = .up
*/

#endif /* AKInterop_h */
