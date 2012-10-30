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
        aOutL  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"Left%i", _myID]];
        aOutR  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"Right%i",_myID]];
    }
    return self;
}

- (id)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        aOutL  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"Left%@%i",  name, _myID]];
        aOutR  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"Right%@%i", name, _myID]];
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

- (id)scaledBy:(float)scalingFactor
{
    OCSAudio *left  = [OCSAudio parameterWithFormat:@"((%@) * %g)", aOutL, scalingFactor];
    OCSAudio *right = [OCSAudio parameterWithFormat:@"((%@) * %g)", aOutR, scalingFactor];
    return [[OCSStereoAudio alloc] initWithLeftInput:left rightInput:right];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", aOutL, aOutR];
}
@end

