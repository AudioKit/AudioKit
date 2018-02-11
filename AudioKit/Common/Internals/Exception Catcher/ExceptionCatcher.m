//
//  ExceptionCatcher.m
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "ExceptionCatcher.h"

void AKTryOperation(void (^ _Nonnull tryBlock)(void),
                    void (^ _Nullable catchBlock)(NSException * _Nonnull))
{
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        if (catchBlock)
            catchBlock(exception);
    }
}

