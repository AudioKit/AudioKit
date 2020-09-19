// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

//  Inspired by https://github.com/RedRoma/SwiftExceptionCatcher

#ifndef ExceptionCatcher_h
#define ExceptionCatcher_h

#import <Foundation/Foundation.h>

void ExceptionCatcherOperation(void (^ _Nonnull tryBlock)(void),
                               void (^ _Nullable catchBlock)(NSException * _Nonnull));

#endif /* ExceptionCatcher_h */
