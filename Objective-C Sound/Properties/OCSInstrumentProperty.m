//
//  OCSInstrumentProperty.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrumentProperty.h"

@implementation OCSInstrumentProperty
@synthesize minimumValue, maximumValue;
@synthesize value=currentValue;
@synthesize name;

- (id)init
{
    self = [super init];
    if (self) {
        [self setName:@"Property"];
    }
    return self;
}

- (id)initWithMinValue:(float)minValue
              maxValue:(float)maxValue;
{
    return [self initWithValue:minValue minValue:minValue maxValue:maxValue];
}

- (id)initWithValue:(float)initialValue
           minValue:(float)minValue
           maxValue:(float)maxValue;
{
    self = [self init];
    if (self) {
        currentValue = initialValue;
        minimumValue = minValue;
        maximumValue = maxValue;
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


- (void)setValue:(Float32)newValue {
    currentValue = newValue;
    if (minimumValue && newValue < minimumValue) {
        currentValue = minimumValue;
        NSLog(@"%@ out of bounds, assigning to minimum", self);
    }
    else if (maximumValue && newValue > maximumValue) {
        currentValue = maximumValue;
        NSLog(@"%@ out of bounds, assigning to maximum", self);
    }
}

- (void)randomize;
{
    float width = maximumValue - minimumValue;
    [self setValue:(((float) rand() / RAND_MAX) * width) + minimumValue];
}

# pragma mark CsoundValueCacheable

-(BOOL)isCacheDirty {
    return NO;
}

- (void)setup:(CsoundObj*)csoundObj {
    channelPtr = [csoundObj getInputChannelPtr:[NSString stringWithFormat:@"%@Pointer",self]];
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
