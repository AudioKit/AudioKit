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
    //NSMutableString *scoreLine;
    MyBlockType block;
    //int _myID;
    //float eventNumber;
    //OCSInstrument *instr;
}
@end

@implementation OCSEvent

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

@synthesize note;

- (id)initWithNote:(OCSNote *)newNote {
    self = [self init];
    if (self) {
        note = newNote;
    }
    return self;
}

- (id)initWithNote:(OCSNote *)newNote block:(void (^)())aBlock {
    self = [self initWithNote:newNote];
    if (self) {
        block = aBlock;
    }
    return self;
}

- (id)initWithBlock:(void (^)())aBlock {
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
    if (self->note) [note play];
}

- (void)runBlock {
    if (self->block) block();
}

- (void)trigger;
{
    [[OCSManager sharedOCSManager] triggerEvent:self];
}

@end
