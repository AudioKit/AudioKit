//
//  OCSInstrumentProperty.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrumentProperty.h"

@implementation OCSInstrumentProperty

@synthesize isMidiEnabled;
@synthesize midiController;
@synthesize cacheDirty = mCacheDirty;


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

- (void)setValue:(Float32)value {
    currentValue = value;
    if (value < minimumValue) {
        currentValue = minimumValue;
        NSLog(@"%@ out of bounds, assigning to minimum", [self output]);
    }
    if (value > maximumValue) {
        currentValue = maximumValue;
        NSLog(@"%@ out of bounds, assigning to maximum", [self output]);
    }
}



# pragma mark CsoundValueCacheable

-(BOOL)isCacheDirty {
    return NO;
}

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


-(void)cleanup {
    
}

@end
