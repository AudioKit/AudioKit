//
//  AKStereoAudio.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"

@implementation AKStereoAudio

+ (instancetype)stereoFromMono:(AKParameter *)mono
{
    return [[AKStereoAudio alloc] initWithLeftAudio:mono rightAudio:mono];
}

- (AKParameter *)leftOutput
{
    if (![self.state isEqualToString:@"artificial"]) {
        _leftOutput.state = @"connectable";
        _leftOutput.dependencies = @[self];
    }
    
    return _leftOutput;
}

- (AKParameter *)rightOutput
{
    if (![self.state isEqualToString:@"artificial"]) {
        _rightOutput.state = @"connectable";
        _rightOutput.dependencies = @[self];
    }
    return _rightOutput;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _leftOutput  = [AKAudio parameterWithString:[NSString stringWithFormat:@"Left%@", @(self.parameterID)]];
        _rightOutput = [AKAudio parameterWithString:[NSString stringWithFormat:@"Right%@",@(self.parameterID)]];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _leftOutput  = [AKAudio parameterWithString:[NSString stringWithFormat:@"Left%@%@",  name, @(self.parameterID)]];
        _rightOutput = [AKAudio parameterWithString:[NSString stringWithFormat:@"Right%@%@", name, @(self.parameterID)]];
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
        self.state = @"artificial";
        self.dependencies = @[_leftOutput, _rightOutput];
    }
    return self;
}

- (instancetype)initGlobalWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _leftOutput  = [AKAudio globalParameterWithString:[NSString stringWithFormat:@"%@Left%@",name, @(self.parameterID)]];
        _rightOutput = [AKAudio globalParameterWithString:[NSString stringWithFormat:@"%@Right%@",name,@(self.parameterID)]];
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

