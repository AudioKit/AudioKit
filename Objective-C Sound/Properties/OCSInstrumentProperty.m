//
//  OCSInstrumentProperty.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrumentProperty.h"

@implementation OCSInstrumentProperty

@synthesize value=currentValue;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setName:@"Property"];
    }
    return self;
}

- (instancetype)initWithMinValue:(float)minValue
              maxValue:(float)maxValue;
{
    return [self initWithValue:minValue minValue:minValue maxValue:maxValue];
}

- (instancetype)initWithValue:(float)initialValue
           minValue:(float)minValue
           maxValue:(float)maxValue;
{
    self = [self init];
    if (self) {
        currentValue = initialValue;
        _minimumValue = minValue;
        _maximumValue = maxValue;
    }
    return self;
}

- (void)setName:(NSString *)newName {
    [self setParameterString:[NSString stringWithFormat:@"k%@%i", newName, _myID]];
}

- (NSString *)stringForCSDGetValue {
    return [NSString stringWithFormat:@"%@ chnget \"%@Pointer\"\n",  self, self];
}

- (NSString *)stringForCSDSetValue {
    return [NSString stringWithFormat:@"chnset %@, \"%@Pointer\"\n", self, self];
}


- (void)setValue:(float)newValue {
    currentValue = newValue;
    if (_minimumValue && newValue < _minimumValue) {
        NSLog(@"%@ = %g is too low using minimum %g", self, newValue, _minimumValue);
        currentValue = _minimumValue;
    }
    else if (_maximumValue && newValue > _maximumValue) {
        NSLog(@"%@ = %g is too high using maximum %g", self, newValue, _maximumValue);
        currentValue = _maximumValue;
    }
}

- (void)randomize;
{
    float width = _maximumValue - _minimumValue;
    [self setValue:(((float) rand() / RAND_MAX) * width) + _minimumValue];
}

# pragma mark CsoundValueCacheable

-(BOOL)isCacheDirty {
    return NO;
}

- (void)setup:(CsoundObj*)csoundObj {
    channelPtr = [csoundObj getInputChannelPtr:[NSString stringWithFormat:@"%@Pointer",self] channelType:CSOUND_CONTROL_CHANNEL];
    *channelPtr = [self value];
}

- (void)updateValuesToCsound {
    *channelPtr = [self value];
}
- (void)updateValuesFromCsound {
    [self setValue:*channelPtr];
}

-(void)cleanup {
    
}



@end
