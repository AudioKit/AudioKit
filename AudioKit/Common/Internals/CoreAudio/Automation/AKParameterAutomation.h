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

//typedef struct AutomationPointList {
//    //    int numberOfPoints;
//    //    AutomationPoint points[1];
//
//    // variable length vector of automationPoints
//    std::vector<AutomationPoint> automationPoints;
//
//    void addPoint(AUParameterAddress address, AUValue value, AUEventSampleTime sampleTime, AUEventSampleTime anchorTime, AUAudioFrameCount rampDuration) {
//        AutomationPoint point = {};
//        point.address = address;
//        point.value = value;
//        point.sampleTime = sampleTime;
//        point.anchorTime = anchorTime;
//        point.rampDuration = rampDuration;
//        addPoint(point);
//    }
//    void addPoint(AutomationPoint point) {
//        automationPoints.push_back(point);
//    }
//
//    void removeAll() {
//        automationPoints.clear();
//    }
//
//} AutomationPointList;

@interface AKParameterAutomation : NSObject

//@property (nonatomic) NSArray *automationPoints;

- (void)initAutomation:(AUAudioUnit * _Nullable)auAudioUnit avAudioUnit:(AVAudioUnit * _Nullable)avAudioUnit;

- (void)startAutomationAt:(AVAudioTime * _Nullable)audioTime;
- (void)stopAutomation;

- (void)addPoint:(AUParameterAddress)address
           value:(AUValue)value
      sampleTime:(AUEventSampleTime)sampleTime
      anchorTime:(AUEventSampleTime)anchorTime
    rampDuration:(AUAudioFrameCount)rampDuration;

- (void)addPoint:(struct AutomationPoint)point;

- (void)clear;
- (void)dispose;

@end

NS_ASSUME_NONNULL_END
