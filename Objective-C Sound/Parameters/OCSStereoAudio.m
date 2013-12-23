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
    return [[OCSStereoAudio alloc] initWithLeftAudio:mono rightAudio:mono];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        aOutL  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"Left%i", _myID]];
        aOutR  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"Right%i",_myID]];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        aOutL  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"Left%@%i",  name, _myID]];
        aOutR  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"Right%@%i", name, _myID]];
    }
    return self;
}

- (instancetype)initWithLeftAudio:(OCSAudio *)leftAudio
                       rightAudio:(OCSAudio *)rightAudio
{
    self = [self init];
    if (self) {
        aOutL = leftAudio;
        aOutR = rightAudio;
    }
    return self;
}

- (id)scaledBy:(OCSParameter *)scalingFactor
{
    OCSAudio *left   = [aOutL scaledBy:scalingFactor];
    OCSAudio *right  = [aOutR scaledBy:scalingFactor];
    return [[OCSStereoAudio alloc] initWithLeftAudio:left rightAudio:right];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", aOutL, aOutR];
}
@end

