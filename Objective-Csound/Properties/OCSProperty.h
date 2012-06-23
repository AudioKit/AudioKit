//
//  OCSProperty.h
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@class OCSParamControl;
#import "BaseValueCacheable.h"

@interface OCSProperty : BaseValueCacheable
{
    Float32 maximumValue;
    Float32 minimumValue;
    Float32 initValue;
    Float32 value;
    
    OCSParamControl * output;
    
    BOOL isAudioRate;
    
    //channelName
    float* channelPtr;
}

@property (nonatomic, readwrite) Float32 value;
@property (nonatomic, readonly) NSString * uniqueIdentifier;
@property (nonatomic, strong) OCSParamControl * output;
@property (nonatomic, assign) Float32 maximumValue;
@property (nonatomic, assign) Float32 minimumValue;
@property (nonatomic, assign) Float32 initValue;

-(id)init;
-(id)initWithValue:(float)aInitValue;
-(id)initWithValue:(float)val Min:(float)min Max:(float)max;
-(id)initWithValue:(float)val Min:(float)min Max:(float)max isAudioRate:(BOOL)control;
-(NSString *)getChannelText;
-(NSString *)setChannelText;
-(NSString *)uniqueName;

-(void)setup:(CsoundObj*)csoundObj;
-(void)updateValuesToCsound;

@end
