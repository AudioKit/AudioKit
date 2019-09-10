//
//  AKParameterAutomation.h
//  AudioKit
//
//  Created by Ryan Francesconi on 9/9/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct AutomationPoint {
    AUParameterAddress address;
    AUValue value;
    AUEventSampleTime sampleTime;
    AUEventSampleTime anchorTime;

    AUAudioFrameCount rampDuration;
    /// it is up to the implementing class to support the ramping scheme
    //var rampType: AKSettings.RampType = .linear

    bool triggered;
} AutomationPoint;

// number of voices
#define MAX_NUMBER_OF_POINTS 256

@interface AKParameterAutomation : NSObject

- (void)initAutomation:(AUAudioUnit * _Nullable)auAudioUnit
           avAudioUnit:(AVAudioUnit * _Nullable)avAudioUnit;

- (void)startAutomationAt:(AVAudioTime * _Nullable)audioTime
                   duration:(AVAudioTime * _Nullable)duration;
- (void)stopAutomation;

- (void)addPoint:(AUParameterAddress)address
           value:(AUValue)value
      sampleTime:(AUEventSampleTime)sampleTime
      anchorTime:(AUEventSampleTime)anchorTime
    rampDuration:(AUAudioFrameCount)rampDuration;

- (void)addPoint:(struct AutomationPoint)point;

- (void)clear;
- (void)dispose;

//@property bool offline;

@end

NS_ASSUME_NONNULL_END
