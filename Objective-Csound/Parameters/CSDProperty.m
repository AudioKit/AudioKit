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

-(id)initWithValue:(float)aInitValue Min:(float)minValue Max:(float)maxValue
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        maximumValue = maxValue;
        minimumValue = minValue;
        initValue = aInitValue;
        value = aInitValue;
        isControl = NO;
        
        output = [CSDParam paramWithFormat:@"ga%@", [self uniqueName]];
        
    }
    return self;
}

-(id)initWithValue:(float)aInitValue Min:(float)minValue Max:(float)maxValue isControlRate:(BOOL)control 
{
    self = [super init];
    
    //Csound manual gives chnget output as a,k,i-rate but csound-iOS doc refers to k-rate only
    if (self) {
        _myID = currentID++;
        maximumValue = maxValue;
        minimumValue = minValue;
        initValue = aInitValue;
        value = aInitValue;
        isControl = control;

        if(isControl)
        {
            output = [CSDParamControl paramWithFormat:@"k%@", [self uniqueName]];
        } else {
            output = [CSDParam paramWithFormat:@"a%@", [self uniqueName]];
            
        }
    }

    return self;
}

-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:@"%@ chnget \"%@\"\n", output, [self uniqueName]];
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
    channelPtr = [csoundObj getInputChannelPtr:[self uniqueName]];
    *channelPtr = [self value];
}

-(void)updateValuesToCsound {
    *channelPtr = [self value];  
}

-(NSString *)description {
    return [output parameterString];
}

@end
