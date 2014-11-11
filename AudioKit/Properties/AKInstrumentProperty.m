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
    [super setValue:newValue];
    isCacheDirty = YES;
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
