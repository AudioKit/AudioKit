//
//  OCSStereoAudio.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSStereoAudio.h"

@interface OCSStereoAudio () {
    OCSAudio *aOutL;
    OCSAudio *aOutR;
    int _myID;
}
@end

@implementation OCSStereoAudio

@synthesize leftOutput=aOutL;
@synthesize rightOutput=aOutR;

static int currentID = 1;

+ (void)resetID {
    currentID = 1;
}

+ (OCSStereoAudio *)stereoFromMono:(OCSAudio *)mono {
    return [[OCSStereoAudio alloc] initWithLeftInput:mono rightInput:mono];
}

- (id)init
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        aOutL  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"aLeft%i",_myID]];
        aOutR  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"aRight%i",_myID]];
    }
    return self;
}

- (id)initWithLeftInput:(OCSAudio *)leftInput
             rightInput:(OCSAudio *)rightInput
{
    self = [self init];
    if (self) {
        aOutL = leftInput;
        aOutR = rightInput;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", aOutL, aOutR];
}
@end

