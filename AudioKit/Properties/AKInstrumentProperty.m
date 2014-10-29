//
//  AKInstrumentProperty.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKInstrumentProperty.h"
#import "CsoundObj.h"

@interface AKInstrumentProperty() <CsoundBinding> {
    MYFLT *channelPtr;
    BOOL isCacheDirty;
}
@end

@implementation AKInstrumentProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setName:@"Property"];
        isCacheDirty = NO;
    }
    return self;
}

- (instancetype)initWithMinimum:(float)minimum
                        maximum:(float)maximum;
{
    return [self initWithValue:minimum
                       minimum:minimum
                       maximum:maximum];
}

- (instancetype)initWithValue:(float)initialValue
                      minimum:(float)minimum
                      maximum:(float)maximum;
{
    self = [self init];
    if (self) {
        _value        = initialValue;
        _initialValue = initialValue;
        _minimum = minimum;
        _maximum = maximum;
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
    if (_minimum && newValue < _minimum) {
        NSLog(@"%@ = %g is too low using minimum %g", self, newValue, _minimum);
        _value = _minimum;
    }
    else if (_maximum && newValue > _maximum) {
        NSLog(@"%@ = %g is too high using maximum %g", self, newValue, _maximum);
        _value = _maximum;
    }
    isCacheDirty = YES;
}

- (void)reset {
    self.value = self.initialValue;
}

- (void)randomize;
{
    float width = _maximum - _minimum;
    [self setValue:(((float) rand() / RAND_MAX) * width) + _minimum];
}

- (void)scaleWithValue:(float)value
               minimum:(float)minimum
               maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    float width = self.maximum - self.minimum;
    self.value = self.minimum + percentage * width;
}

# pragma mark - CsoundBinding

- (void)setup:(CsoundObj*)csoundObj {
    channelPtr = [csoundObj getInputChannelPtr:[NSString stringWithFormat:@"%@Pointer",self] channelType:CSOUND_CONTROL_CHANNEL];
    *channelPtr = self.value;
}

- (void)updateValuesToCsound {
    *channelPtr = self.value;
}
- (void)updateValuesFromCsound {
    if ((isCacheDirty) && (*channelPtr == self.value))
        isCacheDirty = NO;
    if ((!isCacheDirty) && (*channelPtr))
        self.value = *channelPtr;
}

@end
