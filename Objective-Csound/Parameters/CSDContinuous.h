//
//  CSDContinuous.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@class CSDParam;
//#import "CSDManager.h"
#import "BaseValueCacheable.h"

@interface CSDContinuous : BaseValueCacheable
{
    Float32 maximumValue;
    Float32 minimumValue;
    Float32 initValue;
    Float32 value;
    
    CSDParam * output;
    
    BOOL isControl;
    
    //channelName
    NSString * uniqueIdentifier;
    float* channelPtr;
}

@property (nonatomic, readwrite) Float32 value;
@property (nonatomic, readonly) NSString * uniqueIdentifier;
@property (nonatomic, strong) CSDParam * output;
@property (nonatomic, assign) Float32 maximumValue;
@property (nonatomic, assign) Float32 minimumValue;
@property (nonatomic, assign) Float32 initValue;

-(id)init:(float)aInitValue Max:(float)maxValue Min:(float)minValue Tag:(int)aTag;
-(id)init:(float)aInitValue Max:(float)maxValue Min:(float)minValue Tag:(int)aTag isControlRate:(BOOL)control;
-(NSString *)convertToCsd;
-(NSString *)uniqueName;

@end
