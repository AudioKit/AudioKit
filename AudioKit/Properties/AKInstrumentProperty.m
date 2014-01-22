//
//  AKInstrumentProperty.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKInstrumentProperty.h"

@implementation AKInstrumentProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setName:@"Property"];
    }
    return self;
}

- (instancetype)initWithMinimumValue:(float)minimumValue
                        maximumValue:(float)maximumValue;
{
    return [self initWithValue:minimumValue
                  minimumValue:minimumValue
                  maximumValue:maximumValue];
}

- (instancetype)initWithValue:(float)initialValue
                 minimumValue:(float)minimumValue
                 maximumValue:(float)maximumValue;
{
    self = [self init];
    if (self) {
        _value        = initialValue;
        _initialValue = initialValue;
        _minimumValue = minimumValue;
        _maximumValue = maximumValue;
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
    _value = newValue;
    if (_minimumValue && newValue < _minimumValue) {
        NSLog(@"%@ = %g is too low using minimum %g", self, newValue, _minimumValue);
        _value = _minimumValue;
    }
    else if (_maximumValue && newValue > _maximumValue) {
        NSLog(@"%@ = %g is too high using maximum %g", self, newValue, _maximumValue);
        _value = _maximumValue;
    }
}

- (void)reset {
    self.value = self.initialValue;
}

- (void)randomize;
{
    float width = _maximumValue - _minimumValue;
    [self setValue:(((float) rand() / RAND_MAX) * width) + _minimumValue];
}

- (void)scaleWithValue:(float)value
               minimum:(float)minimum
               maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    float width = self.maximumValue - self.minimumValue;
    self.value = self.minimumValue + percentage * width;
}

# pragma mark - CsoundValueCacheable

-(BOOL)isCacheDirty {
    return NO;
}

- (void)setup:(CsoundObj*)csoundObj {
    channelPtr = [csoundObj getInputChannelPtr:[NSString stringWithFormat:@"%@Pointer",self] channelType:CSOUND_CONTROL_CHANNEL];
    *channelPtr = [self value];
}

- (void)updateValuesTAKound {
    *channelPtr = [self value];
}
- (void)updateValuesFromCsound {
    [self setValue:*channelPtr];
}

-(void)cleanup {
    
}



@end
