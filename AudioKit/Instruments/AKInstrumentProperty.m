//
//  AKInstrumentProperty.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/18/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrumentProperty.h"
#import "CsoundObj.h"
#import "csound.h"

@interface AKInstrumentProperty() <CsoundBinding>
{
    float *channelPtr;
    BOOL sentToCsound;
}
@end

@implementation AKInstrumentProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setName:@"Property"];
    }
    return self;
}

- (void)setName:(NSString *)newName
{
    [self setParameterString:[NSString stringWithFormat:@"k%@%@", newName, @(self.parameterID)]];
}

- (NSString *)stringForCSDGetValue
{
    return [NSString stringWithFormat:@"%@ chnget \"%@Pointer\"\n",  self, self];
}

- (NSString *)stringForCSDSetValue
{
    return [NSString stringWithFormat:@"chnset %@, \"%@Pointer\"\n", self, self];
}


- (void)setValue:(float)newValue {
    [super setValue:newValue];
    sentToCsound = NO;
}

// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------

- (void)setup:(CsoundObj*)csoundObj
{
    channelPtr = [csoundObj getInputChannelPtr:[NSString stringWithFormat:@"%@Pointer",self]
                                   channelType:AKControlChannel];
    *channelPtr = self.value;
    sentToCsound = YES;
}

- (void)updateValuesToCsound
{
    if (!sentToCsound)  {
        *channelPtr = self.value;
        sentToCsound = YES;
    }
}

- (void)updateValuesFromCsound
{
    if (sentToCsound) {
        if (self.value != *channelPtr) {
            self.value = *channelPtr;
        }
    }
    
    if ((!sentToCsound) && (*channelPtr == self.value)) {
        sentToCsound = YES;
    }
}

@end
