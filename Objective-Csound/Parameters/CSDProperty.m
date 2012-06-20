//
//  CSDProperty.m
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//

#import "CSDProperty.h"
#import "CSDParamControl.h"

@implementation CSDProperty
@synthesize maximumValue;
@synthesize minimumValue;
@synthesize initValue;
@synthesize value;
@synthesize uniqueIdentifier;
@synthesize output;

static int currentID = 1;

-(id)init;
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        isAudioRate = NO;
        output = [CSDParam paramWithFormat:@"gk%@", [self uniqueName]];
        
    }
    return self;
}

-(id)initWithValue:(float)aInitValue
{
    self = [self init];
    initValue = aInitValue;
    value = aInitValue;

    return self;
}

-(id)initWithValue:(float)aInitValue Min:(float)minValue Max:(float)maxValue
{
    self = [self init];
    initValue = aInitValue;
    value = aInitValue;
    minimumValue = minValue;
    maximumValue = maxValue;
    return self;
}

-(id)initWithValue:(float)aInitValue Min:(float)minValue Max:(float)maxValue isAudioRate:(BOOL)control 
{
    self = [self init];
    initValue = aInitValue;
    value = aInitValue;
    minimumValue = minValue;
    maximumValue = maxValue;
    isAudioRate = control;
    if(isAudioRate) {
        output = [CSDParam paramWithFormat:@"ga%@", [self uniqueName]];
    } 
    return self;
}

-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:@"%@ chnget \"%@\"\n", output, output];
}
                      
+(void) resetID {
    currentID = 1;
}

-(NSString *) uniqueName {
    NSString * basename = [NSString stringWithFormat:@"%@%i", [self class], _myID];
    basename = [basename stringByReplacingOccurrencesOfString:@"CSD" withString:@""];
    return basename;
}
#pragma mark BaseValueCacheable
-(void)setup:(CsoundObj*)csoundObj {
    channelPtr = [csoundObj getInputChannelPtr:[output parameterString]];
    *channelPtr = [self value];
}

-(void)updateValuesToCsound {
    *channelPtr = [self value];  
}

-(NSString *)description {
    return [output parameterString];
}

@end
