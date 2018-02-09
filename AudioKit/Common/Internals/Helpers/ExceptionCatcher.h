//
//  ExceptionCatcher.h
//  AudioKit For iOS
//
//  Created by Stéphane Peter, revision history on Github.
//  Inspired by https://github.com/RedRoma/SwiftExceptionCatcher
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifndef ExceptionCatcher_h
#define ExceptionCatcher_h

#import <Foundation/Foundation.h>

void AKTryOperation(void (^ _Nonnull tryBlock)(void),
                    void (^ _Nullable catchBlock)(NSException * _Nonnull),
                    void (^ _Nullable finallyBlock)(void));

#endif /* ExceptionCatcher_h */
