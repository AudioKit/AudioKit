// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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

