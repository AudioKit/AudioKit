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
    AKBlockType block;
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (instancetype)initWithBlock:(void (^)())aBlock
{
    self = [self init];
    if (self) {
        block = aBlock;
    }
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - event Actions
// -----------------------------------------------------------------------------

- (void)runBlock
{
    if (self->block) block();
}

- (void)trigger;
{
    [[AKManager sharedManager] triggerEvent:self];
}

@end
