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
    /// TODO: it is up to the implementing class to support the ramping scheme
    //var rampType: AKSettings.RampType = .linear

    bool triggered;
} AutomationPoint;

// The max number of automation points supported by this class
// Can be variable in the future...
#define MAX_NUMBER_OF_POINTS 256

@interface AKParameterAutomation : NSObject

/**
 Creates an automation object that controls the AUAudioUnit's parameters.
 The AVAudioUnit is passed to an internal AKTimelineTap for timing references.
 Note: offline automation rendering is only available in macOS 10.13+, iOS 11+
 */
- (instancetype _Nullable)init:(AUAudioUnit *_Nullable)auAudioUnit
                   avAudioUnit:(AVAudioUnit *_Nullable)avAudioUnit;

/** Start the automation at some point in the future.
 duration is not yet implemented.
 */
- (void)startAutomationAt:(AVAudioTime *_Nullable)audioTime
                 duration:(AVAudioTime *_Nullable)duration;

/** Stop automation and the internal timeline */
- (void)stopAutomation;

/** Add a single automation point to the collection */
- (void)addPoint:(AUParameterAddress)address
           value:(AUValue)value
      sampleTime:(AUEventSampleTime)sampleTime
      anchorTime:(AUEventSampleTime)anchorTime
    rampDuration:(AUAudioFrameCount)rampDuration;

/** Add a single automation point to the collection */
- (void)addPoint:(struct AutomationPoint)point;

/** Removes all automation points */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
