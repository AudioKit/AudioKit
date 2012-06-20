//
//  CSDContinuous.h
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@class CSDParam;
#import "BaseValueCacheable.h"

@interface CSDContinuous : BaseValueCacheable
{
    int _myID;
    Float32 maximumValue;
    Float32 minimumValue;
    Float32 initValue;
    Float32 value;
    
    CSDParam * output;
    
    BOOL isControl;
    
    //channelName
    float* channelPtr;
}

@property (nonatomic, readwrite) Float32 value;
@property (nonatomic, readonly) NSString * uniqueIdentifier;
@property (nonatomic, strong) CSDParam * output;
@property (nonatomic, assign) Float32 maximumValue;
@property (nonatomic, assign) Float32 minimumValue;
@property (nonatomic, assign) Float32 initValue;

-(id)initWithValue:(float)aInitValue Min:(float)minValue Max:(float)maxValue;
-(id)initWithValue:(float)aInitValue Min:(float)minValue Max:(float)maxValue isControlRate:(BOOL)control;
-(NSString *)convertToCsd;
-(NSString *)uniqueName;
+(void) resetID;

-(void)setup:(CsoundObj*)csoundObj;
-(void)updateValuesToCsound;

@end
