//
//  AKEvent.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKEvent.h"
#import "AKManager.h"

typedef void (^MyBlockType)();

@implementation AKEvent
{
    MyBlockType block;
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (instancetype)initWithNote:(AKNote *)newNote {
    self = [self init];
    if (self) {
        _note = newNote;
    }
    return self;
}

- (instancetype)initWithNote:(AKNote *)newNote block:(void (^)())aBlock {
    self = [self initWithNote:newNote];
    if (self) {
        block = aBlock;
    }
    return self;
}

- (instancetype)initWithBlock:(void (^)())aBlock {
    self = [self init];
    if (self) {
        block = aBlock;
    }
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - event Actions
// -----------------------------------------------------------------------------

- (void)playNote {
    if (self->_note) [_note play];
}

- (void)runBlock {
    if (self->block) block();
}

- (void)trigger;
{
    [[AKManager sharedAKManager] triggerEvent:self];
}

@end
