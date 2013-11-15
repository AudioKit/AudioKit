//
//  OCSEvent.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSEvent.h"
#import "OCSManager.h"

typedef void (^MyBlockType)();

@interface OCSEvent () {
    MyBlockType block;
}
@end

@implementation OCSEvent

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (instancetype)initWithNote:(OCSNote *)newNote {
    self = [self init];
    if (self) {
        _note = newNote;
    }
    return self;
}

- (instancetype)initWithNote:(OCSNote *)newNote block:(void (^)())aBlock {
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
    [[OCSManager sharedOCSManager] triggerEvent:self];
}

@end
