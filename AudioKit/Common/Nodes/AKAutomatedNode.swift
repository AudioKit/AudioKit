//
//  AKAutomatedNode.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 9/7/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Cocoa

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
            // self.automationPointsAccessQueue.sync {
            self._automationPoints = newValue
            // }
        }
    }

//    private lazy var inRefCon: UnsafeMutableRawPointer? = {
//        UnsafeMutableRawPointer(Unmanaged<AKAutomatedNode>.passUnretained(self).toOpaque())
//    }()

    public var hasAutomation: Bool {
        return !self.automationPoints.isEmpty
    }

    private var pointsValidated: Bool = false

    private var selfPointer: UnsafeMutableRawPointer?

    private var _automationEnabled: Bool = false
    fileprivate var automationEnabled: Bool {
        get {
            return self._automationEnabled

            //            return self.automationAccessQueue.sync {
//                _automationEnabled
//            }
        }
        set {
            // self.automationAccessQueue.sync {
            guard newValue != self._automationEnabled,
                let audioUnit = avAudioUnit?.audioUnit else {
                return
            }
            AKLog(newValue, "current points:", self.automationPoints)

            // let pointer = Unmanaged<AKAutomatedNode>.passRetained(self).toOpaque()
            // let inRefCon = UnsafeMutableRawPointer(pointer)

            if newValue {
                selfPointer = Unmanaged.passUnretained(self).toOpaque()

                if AudioUnitAddRenderNotify(audioUnit, renderCallback, selfPointer) != noErr {
                    AKLog("ERROR adding the renderNotify")
                }
            } else {
                if AudioUnitRemoveRenderNotify(audioUnit, renderCallback, selfPointer) != noErr {
                    AKLog("ERROR removing the renderNotify")
                }
                selfPointer = nil
            }

            self._automationEnabled = newValue
            // }
        }
    }

    public var lastRenderSampleTime: AUEventSampleTime {
        guard let nodeTime = outputNode.lastRenderTime?.audioTimeStamp.mSampleTime else {
            AKLog("outputNode.lastRenderTime is invalid")
            return 0
        }

        var lastRenderTime = AUEventSampleTime(nodeTime)

        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            if let engine = avAudioNode.engine, engine.manualRenderingMode == .offline {
                lastRenderTime = engine.manualRenderingSampleTime
            }
        }
        return lastRenderTime
    }

//    let renderCallback: AURenderCallback = {
//        (inRefCon: UnsafeMutableRawPointer,
//         ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
//         inTimeStamp: UnsafePointer<AudioTimeStamp>,
//         inBusNumber: UInt32,
//         inNumberFrames: UInt32,
//         ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus in
//
    ////        let preRender = ioActionFlags.pointee == AudioUnitRenderActionFlags.unitRenderAction_PreRender
    ////        guard preRender else { return noErr }
    ////
    ////        let ref = Unmanaged<AKAutomatedNode>.fromOpaque(inRefCon)
    ////        let node: AKAutomatedNode = ref.takeUnretainedValue()
    ////
    ////    //        let ref = Unmanaged<AKAutomatedNode>.fromOpaque(inRefCon)
    ////    //        let node: AKAutomatedNode = ref.takeRetainedValue()
    ////
    ////        let sampleTime = AUEventSampleTime(inTimeStamp.pointee.mSampleTime)
    ////
    ////        // this callback is happening from the render thread
    ////        node.handleRenderCallback(at: sampleTime, inNumberFrames: inNumberFrames)
//
//        let delegate = unsafeBitCast(inRefCon, to: AURenderCallbackDelegate.self)
//        let result = delegate.performRender(ioActionFlags: ioActionFlags,
//                                            inTimeStamp: inTimeStamp,
//                                            inBusNumber: inBusNumber,
//                                            inNumberFrames: inNumberFrames,
//                                            ioData: ioData)
//        return result
//
//        //return noErr
//    }

    /// typedef void (^AUScheduleParameterBlock)(AUEventSampleTime eventSampleTime, AUAudioFrameCount rampDurationSampleFrames, AUParameterAddress parameterAddress, AUValue value);
    fileprivate func handleRenderCallback(at sampleTime: AUEventSampleTime, inNumberFrames: UInt32) {
        guard let auUnit = self.avAudioUnit?.auAudioUnit else { return }

//        guard !self.automationPoints.isEmpty else { return }

        // AKLog(sampleTime, inNumberFrames)

        // only do this once per render session: "automationEnabled"
//        if !self.pointsValidated {
//            self.validatePoints(at: sampleTime)
//            self.pointsValidated = true
//        }

        for point in self.automationPoints {
            if point.offsetTime == AUEventSampleTimeImmediate {
                AKLog("👍 triggering value", point.value, "AUEventSampleTimeImmediate at", sampleTime)
                auUnit.scheduleParameterBlock(AUEventSampleTimeImmediate,
                                                                     point.rampDuration,
                                                                     point.address,
                                                                     point.value)

                point.offsetTime = -1 // it's triggered
                point.lastRenderTime = -1
                continue
            }

            let pointTime = point.offsetTime + point.lastRenderTime

            // scan from sampleTime to inNumberFrames for any matching events in that range
            for n in 0 ..< inNumberFrames {
                // if fmod(Double(sampleTime) + Double(i), Double(point.sampleTime)) == 0 {
                let offsetFrames = AUEventSampleTime(n)
                let renderTime = sampleTime + offsetFrames

                if renderTime == pointTime {
                    AKLog("👉 triggering value", point.value, "at", sampleTime, "offsetFrames", offsetFrames, "point.absoluteTime", point.absoluteTime)

                    auUnit.scheduleParameterBlock(AUEventSampleTimeImmediate + offsetFrames,
                                                                         point.rampDuration,
                                                                         point.address,
                                                                         point.value)

                    point.offsetTime = -1
                    point.lastRenderTime = -1
                }
            }
        }
    }

    /// this method does two things, first checks for any points marked
    /// AUEventSampleTimeImmediate, and second if a point is in the queue
    /// but is late, restamp it to the current sampleTime so that
    /// handleRenderCallback will fire it off.
    private func validatePoints() {
        // at sampleTime: AUEventSampleTime
        let sampleTime = lastRenderSampleTime

        for i in 0 ..< self.automationPoints.count {
            if self.automationPoints[i].offsetTime == AUEventSampleTimeImmediate {
                continue
            }
            // then remove these points?
            // support AUEventSampleTimeImmediate as a value for offsetTime
//            if self.automationPoints[i].offsetTime == AUEventSampleTimeImmediate {
//                AKLog("👍 triggering value", self.automationPoints[i].value, "immediately at", sampleTime)
//                self.avAudioUnit?.auAudioUnit.scheduleParameterBlock(AUEventSampleTimeImmediate,
//                                                                     self.automationPoints[i].rampDuration,
//                                                                     self.automationPoints[i].address,
//                                                                     self.automationPoints[i].value)

            // a point is late. this could be turned into immediate?
            // } else

            if self.automationPoints[i].absoluteTime < sampleTime {
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

    public func addAutomationPoint(point: AKParameterAutomationPoint) {
        self.automationPoints.append(point)
        AKLog("* adding", point.value, "at", point.offsetTime, "lastRenderTime", point.lastRenderTime, "point.absoluteTime", point.absoluteTime, "total points", self.automationPoints.count)
    }

    public func startAutomation() {
        guard !automationEnabled else { return }
        // if !self.pointsValidated {
        self.validatePoints()
        //    self.pointsValidated = true
        // }
        self.automationEnabled = true
    }

    public func stopAutomation() {
        guard automationEnabled else { return }

        AKLog("Remove All Points, AudioUnitRemoveRenderNotify etc")
        self.automationEnabled = false
        self.automationPoints.removeAll()
        self.pointsValidated = false
    }
}

extension AKAutomatedNode: AURenderCallbackDelegate {
    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                       inTimeStamp: UnsafePointer<AudioTimeStamp>,
                       inBusNumber: UInt32,
                       inNumberFrames: UInt32,
                       ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
        guard ioActionFlags.pointee == AudioUnitRenderActionFlags.unitRenderAction_PreRender else { return noErr }

        self.handleRenderCallback(at: AUEventSampleTime(inTimeStamp.pointee.mSampleTime), inNumberFrames: inNumberFrames)
        return noErr
    }
}

@objc open class AKParameterAutomationPoint: NSObject {
    var address: AUParameterAddress = 0
    var value: AUValue = 0
    var offsetTime: AUEventSampleTime = 0
    var lastRenderTime: AUEventSampleTime = 0

    var rampDuration: AUAudioFrameCount = 0
    /// it is up to the implementing class to support the ramping scheme
    var rampType: AKSettings.RampType = .linear

    var absoluteTime: AUEventSampleTime {
        return self.offsetTime + self.lastRenderTime
    }

    open override var description: String {
        return "AKParameterAutomationPoint address \(self.address) value \(self.value) " +
            "offsetTime \(self.offsetTime) lastRenderTime \(self.lastRenderTime), absoluteTime \(self.absoluteTime) " +
            "rampDuration \(self.rampDuration) rampType \(self.rampType)"
    }

    public init(address: AUParameterAddress,
                value: AUValue,
                offsetTime: AUEventSampleTime,
                lastRenderTime: AUEventSampleTime,
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

@objc protocol AURenderCallbackDelegate {
    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                       inTimeStamp: UnsafePointer<AudioTimeStamp>,
                       inBusNumber: UInt32,
                       inNumberFrames: UInt32,
                       ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
}

func renderCallback(inRefCon: UnsafeMutableRawPointer,
                    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                    inTimeStamp: UnsafePointer<AudioTimeStamp>,
                    inBusNumber: UInt32,
                    inNumberFrames: UInt32,
                    ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    let delegate = unsafeBitCast(inRefCon, to: AURenderCallbackDelegate.self)

    let result = delegate.performRender(ioActionFlags: ioActionFlags,
                                        inTimeStamp: inTimeStamp,
                                        inBusNumber: inBusNumber,
                                        inNumberFrames: inNumberFrames,
                                        ioData: ioData)
    return result
}

// public struct AKParameterAutomationPoint {
//    var address: AUParameterAddress
//    var value: AUValue = 0
//    var offsetTime: AUEventSampleTime = 0
//    var lastRenderTime: AUEventSampleTime = 0
//
//    var rampDuration: AUAudioFrameCount = 0
//    /// it is up to the implementing class to support the ramping scheme
//    var rampType: AKSettings.RampType = .linear
//
//    var absoluteTime: AUEventSampleTime {
//        return self.offsetTime + self.lastRenderTime //(self.lastRenderTime ?? 0)
//    }
//
//    var triggered: Bool = false
// }
