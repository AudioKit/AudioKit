//
//  CSDContinuous.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

#import "CSDParam.h"
@class CSDManager;

@interface CSDContinuous : NSObject
{
    Float32 maximumValue;
    Float32 minimumValue;
    Float32 initValue;
    Float32 value;
    
    NSString * uniqueIdentifier;
}

@property (nonatomic, readwrite) Float32 value;
@property (nonatomic, readonly) NSString * uniqueIdentifier;
@property (nonatomic, assign) Float32 maximumValue;
@property (nonatomic, assign) Float32 minimumValue;
@property (nonatomic, assign) Float32 initValue;

-(id)init:(float)aInitValue Max:(float)maxValue Min:(float)minValue Tag:(int)aTag;
-(NSString *)convertToCsd;

@end
