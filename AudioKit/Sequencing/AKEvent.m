//
//  AKEvent.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKEvent.h"
#import "AKManager.h"

/// Define a block type helper
typedef void (^AKBlockType)();

@implementation AKEvent
{
    AKBlockType _block;
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (instancetype)initWithBlock:(void (^)())aBlock
{
    self = [self init];
    if (self) {
        _block = aBlock;
    }
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - event Actions
// -----------------------------------------------------------------------------

- (void)runBlock
{
    if (_block)
        _block();
}

- (void)trigger
{
    [[AKManager sharedManager] triggerEvent:self];
}

@end
