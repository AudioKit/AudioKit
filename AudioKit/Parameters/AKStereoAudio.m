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
    int _myID;
}

static int currentID = 1;

+ (void)resetID
{
    currentID = 1;
}

+ (instancetype)stereoFromMono:(AKParameter *)mono
{
    return [[AKStereoAudio alloc] initWithLeftAudio:mono rightAudio:mono];
}

- (AKParameter *)leftOutput
{
    _leftOutput.state = @"connectable";
    _leftOutput.dependencies = @[self];
    return _leftOutput;
}

- (AKParameter *)rightOutput
{
    _rightOutput.state = @"connectable";
    _rightOutput.dependencies = @[self];
    return _rightOutput;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        _leftOutput  = [AKAudio parameterWithString:[NSString stringWithFormat:@"Left%i", _myID]];
        _rightOutput = [AKAudio parameterWithString:[NSString stringWithFormat:@"Right%i",_myID]];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        _leftOutput  = [AKAudio parameterWithString:[NSString stringWithFormat:@"Left%@%i",  name, _myID]];
        _rightOutput = [AKAudio parameterWithString:[NSString stringWithFormat:@"Right%@%i", name, _myID]];
    }
    return self;
}

- (instancetype)initWithLeftAudio:(AKParameter *)leftAudio
                       rightAudio:(AKParameter *)rightAudio
{
    self = [self init];
    if (self) {
        _leftOutput  = leftAudio;
        _rightOutput = rightAudio;
    }
    return self;
}

- (instancetype)initGlobalWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        _leftOutput  = [AKAudio globalParameterWithString:[NSString stringWithFormat:@"%@Left%i",name, _myID]];
        _rightOutput = [AKAudio globalParameterWithString:[NSString stringWithFormat:@"%@Right%i",name,_myID]];
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
    AKParameter *left  = [_leftOutput scaledBy:scalingFactor];
    AKParameter *right = [_rightOutput scaledBy:scalingFactor];
    return [[AKStereoAudio alloc] initWithLeftAudio:left rightAudio:right];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@", _leftOutput, _rightOutput];
}
@end

