//
//  AKStereoAudio.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"

@implementation AKStereoAudio
{
    AKParameter *aOutL;
    AKParameter *aOutR;
    int _myID;
}

@synthesize leftOutput=aOutL;
@synthesize rightOutput=aOutR;

static int currentID = 1;

+ (void)resetID
{
    currentID = 1;
}

+ (AKStereoAudio *)stereoFromMono:(AKParameter *)mono
{
    return [[AKStereoAudio alloc] initWithLeftAudio:mono rightAudio:mono];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        aOutL  = [AKAudio parameterWithString:[NSString stringWithFormat:@"Left%i", _myID]];
        aOutR  = [AKAudio parameterWithString:[NSString stringWithFormat:@"Right%i",_myID]];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        aOutL  = [AKAudio parameterWithString:[NSString stringWithFormat:@"Left%@%i",  name, _myID]];
        aOutR  = [AKAudio parameterWithString:[NSString stringWithFormat:@"Right%@%i", name, _myID]];
    }
    return self;
}

- (instancetype)initWithLeftAudio:(AKParameter *)leftAudio
                       rightAudio:(AKParameter *)rightAudio
{
    self = [self init];
    if (self) {
        aOutL = leftAudio;
        aOutR = rightAudio;
    }
    return self;
}

- (instancetype)initGlobalWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        aOutL  = [AKAudio globalParameterWithString:[NSString stringWithFormat:@"%@Left%i",name, _myID]];
        aOutR  = [AKAudio globalParameterWithString:[NSString stringWithFormat:@"%@Right%i",name,_myID]];
    }
    return self;
}

+ (instancetype)globalParameter
{
    return [[self alloc] initGlobalWithString:@"Global"];
}

+ (instancetype)globalParameterWithString:(NSString *)name
{
    return [[self alloc] initGlobalWithString:name];
}

- (instancetype)scaledBy:(AKParameter *)scalingFactor
{
    AKParameter *left   = [aOutL scaledBy:scalingFactor];
    AKParameter *right  = [aOutR scaledBy:scalingFactor];
    return [[AKStereoAudio alloc] initWithLeftAudio:left rightAudio:right];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@", aOutL, aOutR];
}
@end

