//
//  AKAutomatedNode.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 9/7/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Cocoa

/*
@objc open class AKParameterAutomationPoint: NSObject {
    var address: AUParameterAddress?
    var value: AUValue = 0
    var offsetTime: AUEventSampleTime = 0
    var lastRenderTime: AUEventSampleTime?

    var rampDuration: AUAudioFrameCount = 0
    /// it is up to the implementing class to support the ramping scheme
    var rampType: AKSettings.RampType = .linear

    var absoluteTime: AUEventSampleTime {
        return self.offsetTime + (self.lastRenderTime ?? 0)
    }

    public init(address: AUParameterAddress?,
                value: AUValue,
                offsetTime: AUEventSampleTime,
                lastRenderTime: AUEventSampleTime?,
                rampDuration: AUAudioFrameCount,
                rampType: AKSettings.RampType = .linear) {
        super.init()
        self.address = address
        self.value = value
        self.offsetTime = offsetTime
        self.rampDuration = rampDuration
        self.lastRenderTime = lastRenderTime
        self.rampType = rampType
    }
}
*/

public struct AKParameterAutomationPoint {
    var address: AUParameterAddress
    var value: AUValue = 0
    var offsetTime: AUEventSampleTime = 0
    var lastRenderTime: AUEventSampleTime = 0

    var rampDuration: AUAudioFrameCount = 0
    /// it is up to the implementing class to support the ramping scheme
    var rampType: AKSettings.RampType = .linear

    var absoluteTime: AUEventSampleTime {
        return self.offsetTime + self.lastRenderTime //(self.lastRenderTime ?? 0)
    }

    var triggered: Bool = false
}

@objc open class AKAutomatedNode: AKNode {
    private let automationAccessQueue = DispatchQueue(label:
        "AKAutomatedNode.automationAccessQueue")

    // Serializes all access to `automationPoints`.
    private let automationPointsAccessQueue = DispatchQueue(label:
        "AKAutomatedNode.automationPointsAccessQueue")

    private var _automationPoints = [AKParameterAutomationPoint]()
    private var automationPoints: [AKParameterAutomationPoint] {
        get {
            return self._automationPoints
//            return self.automationPointsAccessQueue.sync {
//                self._automationPoints
//            }
        }

        set {
            //self.automationPointsAccessQueue.sync {
            self._automationPoints = newValue
            //}
        }
    }

//    private lazy var inRefCon: UnsafeMutableRawPointer? = {
//        UnsafeMutableRawPointer(Unmanaged<AKAutomatedNode>.passUnretained(self).toOpaque())
//    }()

    private var pointsValidated: Bool = false

    private var _automationEnabled: Bool = false
    internal var automationEnabled: Bool {
        get {
            return self._automationEnabled

            //            return self.automationAccessQueue.sync {
//                _automationEnabled
//            }
        }
        set {
            //self.automationAccessQueue.sync {
            guard newValue != self._automationEnabled,
                let audioUnit = avAudioUnit?.audioUnit else {
                return
            }
            AKLog(newValue, "current points:", self.automationPoints)

            let pointer = Unmanaged<AKAutomatedNode>.passUnretained(self).toOpaque()
            let inRefCon = UnsafeMutableRawPointer(pointer)

            if newValue {
                if AudioUnitAddRenderNotify(audioUnit, self.renderCallback, inRefCon) != noErr {
                    AKLog("ERROR adding the renderNotify")
                }
            } else {
                if AudioUnitRemoveRenderNotify(audioUnit, self.renderCallback, inRefCon) != noErr {
                    AKLog("ERROR removing the renderNotify")
                }
//                    self.removeAllAutomation()
            }
            self._automationEnabled = newValue
            //}
        }
    }

    let renderCallback: AURenderCallback = {
        (inRefCon: UnsafeMutableRawPointer,
         ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
         inTimeStamp: UnsafePointer<AudioTimeStamp>,
         inBusNumber: UInt32,
         inNumberFrames: UInt32,
         ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus in

        let preRender = ioActionFlags.pointee.contains(AudioUnitRenderActionFlags.unitRenderAction_PreRender)
        guard preRender else { return noErr }

        let ref = Unmanaged<AKAutomatedNode>.fromOpaque(inRefCon)
        let node: AKAutomatedNode = ref.takeUnretainedValue()

        let sampleTime = AUEventSampleTime(inTimeStamp.pointee.mSampleTime)
        DispatchQueue.main.async {
            node.handleRenderCallback(at: sampleTime, inNumberFrames: inNumberFrames)
        }

        return noErr
    }

    public func addAutomationPoint(point: AKParameterAutomationPoint) {
        self.automationPoints.append(point)
        AKLog("* adding", point.value, "at", point.offsetTime, "lastRenderTime", point.lastRenderTime, "point.absoluteTime", point.absoluteTime, "total points", self.automationPoints.count)
    }

    /// typedef void (^AUScheduleParameterBlock)(AUEventSampleTime eventSampleTime, AUAudioFrameCount rampDurationSampleFrames, AUParameterAddress parameterAddress, AUValue value);
    fileprivate func handleRenderCallback(at sampleTime: AUEventSampleTime, inNumberFrames: UInt32) {
        guard !self.automationPoints.isEmpty else { return }

        //AKLog(sampleTime, inNumberFrames)

        // only do this once per render session: "automationEnabled"
        if !self.pointsValidated {
            self.validatePoints(at: sampleTime)
            self.pointsValidated = true
        }

        for point in self.automationPoints {
            let pointTime = point.offsetTime + point.lastRenderTime

            // scan from sampleTime to inNumberFrames for any matching events in that range
            for i in 0 ..< inNumberFrames {
                // if fmod(Double(sampleTime) + Double(i), Double(point.sampleTime)) == 0 {
                let offsetFrames = AUEventSampleTime(i)
                let renderTime = sampleTime + offsetFrames

                if renderTime == pointTime {
                    AKLog("👉 triggering value", point.value, "at", sampleTime, "offsetFrames", offsetFrames, "point.absoluteTime", point.absoluteTime)

                    self.avAudioUnit?.auAudioUnit.scheduleParameterBlock(AUEventSampleTimeImmediate + offsetFrames,
                                                                         point.rampDuration,
                                                                         point.address,
                                                                         point.value)
                }
            }
        }
    }

    private func validatePoints(at sampleTime: AUEventSampleTime) {
        for i in 0 ..< self.automationPoints.count {
            // support AUEventSampleTimeImmediate as a value for offsetTime
            if self.automationPoints[i].offsetTime == AUEventSampleTimeImmediate {
                AKLog("👍 triggering value", self.automationPoints[i].value, "immediately at", sampleTime)
                self.avAudioUnit?.auAudioUnit.scheduleParameterBlock(AUEventSampleTimeImmediate,
                                                                     self.automationPoints[i].rampDuration,
                                                                     self.automationPoints[i].address,
                                                                     self.automationPoints[i].value)

            } else if self.automationPoints[i].absoluteTime < sampleTime {
                AKLog("-> Adjusted late point's time to", sampleTime, "was", self.automationPoints[i].absoluteTime)
                self.automationPoints[i].offsetTime = 0
                self.automationPoints[i].lastRenderTime = sampleTime
            }
        }
    }

//    public func removeOldAutomation() {
//        guard let internalAU = avAudioUnit?.auAudioUnit as? AKAudioUnitBase else { return }
//
//        self.automationPoints = self.automationPoints.filter {
//            $0.lastRenderTime ?? 0 >= internalAU.lastRenderTime
//        }
//    }
//
//    public func removeAutomation(before sampleTime: AUEventSampleTime) {
//        self.automationPoints = self.automationPoints.filter {
//            $0.absoluteTime >= sampleTime
//        }
//    }

    public func removeAllAutomation() {
        AKLog("Remove All")
        //self.automationEnabled = false

        self.automationPoints.removeAll()

        self.pointsValidated = false
    }
}
