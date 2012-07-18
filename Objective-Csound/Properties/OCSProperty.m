//
//  OCSProperty.m
//  Objective-Csound
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//

#import "OCSProperty.h"

@interface OCSProperty () {
    Float32 maximumValue;
    Float32 minimumValue;
    Float32 initValue;
    Float32 currentValue;
    
    OCSParameter *audio;
    OCSControl *control;
    OCSConstant *constant;
    OCSParameter *output;
    
    //channelName
    float* channelPtr;
    
    BOOL isMidiEnabled;
    int midiController;
}
@end

@implementation OCSProperty
@synthesize maximumValue;
@synthesize minimumValue;
@synthesize initValue;
@synthesize value = currentValue;
@synthesize audio;
@synthesize control;
@synthesize constant;
@synthesize output;
@synthesize isMidiEnabled;
@synthesize midiController;

/// Initializes to default values
- (id)init
{
    self = [super init];
    if (self) {
        // ARB / AOP - need to investigate why this can't be a-rate
        audio    = [OCSParameter parameterWithString:@"Property"];
        control  = [OCSControl parameterWithString:@"Property"];
        constant = [OCSConstant parameterWithString:@"Property"];
        output = control;
        
    }
    return self;
}

- (id)initWithMinValue:(float)minValue 
              maxValue:(float)maxValue;
{
    self = [self init];
    minimumValue = minValue;
    maximumValue = maxValue;
    return self;
}

- (id)initWithValue:(float)initialValue 
           minValue:(float)minValue 
           maxValue:(float)maxValue;
{
    self = [self init];
    initValue = initialValue;
    currentValue = initialValue;
    minimumValue = minValue;
    maximumValue = maxValue;
    return self;
}

- (void)setAudio:(OCSParameter *)p {
    audio = p;
    output = audio;
}

- (void)setControl:(OCSControl *)p {
    control = p;
    output = control;
}
- (void)setConstant:(OCSConstant *)p {
    constant = p;
    output = constant;
}

- (void)setValue:(Float32)value {
    currentValue = value;
    if (value < minimumValue) {
        currentValue = minimumValue;
        NSLog(@"Out of bounds, assigning to minimum");
    }
    if (value > maximumValue) {
        currentValue = maximumValue;
        NSLog(@"Out of bounds, assigning to maximum");
    }
}

- (NSString *)stringForCSDGetValue {
    return [NSString stringWithFormat:@"%@ chnget \"%@Property\"\n",  output, output];
}

- (NSString *)stringForCSDSetValue {
    return [NSString stringWithFormat:@"chnset %@, \"%@Property\"\n", output, output];
}

-(void)enableMidiForControllerNumber:(int)controllerNumber
{
    isMidiEnabled = YES;
    midiController = controllerNumber;
}

#pragma mark BaseValueCacheable

- (void)setup:(CsoundObj*)csoundObj {
    channelPtr = [csoundObj getInputChannelPtr:[NSString stringWithFormat:@"%@Property",[output parameterString]]];
    *channelPtr = [self value];
}

- (void)updateValuesToCsound {
    *channelPtr = [self value];  
}
- (void)updateValuesFromCsound {
    [self setValue:*channelPtr];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
