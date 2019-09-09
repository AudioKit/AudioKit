//
//  AKAutomatedNode.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 9/7/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Cocoa

/**
 An AKNode subclass that supports AudioUnit parameter automation
 */
@objc open class AKAutomatedNode: AKNode {
    // MARK: - private properties

    private var automationPoints = [AKParameterAutomationPoint]()
    private var selfPointer: UnsafeMutableRawPointer?

    private var _automationEnabled: Bool = false
    fileprivate var automationEnabled: Bool {
        get {
            return self._automationEnabled
        }
        set {
            guard newValue != self._automationEnabled,
                let audioUnit = avAudioUnit?.audioUnit else {
                return
            }

            if newValue {
                AKLog("▶️", newValue, self.selfPointer)
                if self.selfPointer == nil {
                    self.selfPointer = Unmanaged.passUnretained(self).toOpaque()
                    if AudioUnitAddRenderNotify(audioUnit, renderCallback, self.selfPointer) != noErr {
                        AKLog("ERROR adding the renderNotify")
                    }
                }

            } else {
                AKLog("⏹", newValue, self.selfPointer)

                if self.selfPointer != nil {
                    if AudioUnitRemoveRenderNotify(audioUnit, renderCallback, self.selfPointer) != noErr {
                        AKLog("ERROR removing the renderNotify")
                    }
                }
                // self.selfPointer = nil // release this
            }
            self._automationEnabled = newValue
        }
    }

    // MARK: - public properties

    @objc public var hasAutomation: Bool {
        return !self.automationPoints.isEmpty
    }

    /// Returns either the outputNode's lastRenderTime or in offline rendering mode,
    /// the engine's manualRenderingSampleTime
    @objc public var lastRenderSampleTime: AUEventSampleTime {
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

    // MARK: - private functions

    /// typedef void (^AUScheduleParameterBlock)(AUEventSampleTime eventSampleTime, AUAudioFrameCount rampDurationSampleFrames, AUParameterAddress parameterAddress, AUValue value);
    fileprivate func handleRenderCallback(at sampleTime: AUEventSampleTime, inNumberFrames: UInt32) {
        guard self.automationEnabled, let auUnit = self.avAudioUnit?.auAudioUnit else { return }

        AKLog(sampleTime, inNumberFrames)
        
        // ignore points that have been already triggered
        for point in self.automationPoints where !point.triggered {
            // allow for triggering via AUEventSampleTimeImmediate
            if point.offsetTime == AUEventSampleTimeImmediate {
                AKLog("👍 triggering value", point.value, "AUEventSampleTimeImmediate at", sampleTime)
                auUnit.scheduleParameterBlock(AUEventSampleTimeImmediate,
                                              point.rampDuration,
                                              point.address,
                                              point.value)

                point.triggered = true // it's triggered
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

                    point.triggered = true
                }
            }
        }
    }

    /// if a point is in the queue but is late, restamp it to the current
    /// sampleTime so that handleRenderCallback will fire it off.
    private func validatePoints() {
        self.removeOldAutomation()

        let sampleTime = lastRenderSampleTime

        for point in self.automationPoints where point.offsetTime != AUEventSampleTimeImmediate {
            if point.absoluteTime < sampleTime {
                AKLog("→→→ Adjusted late point's time to", sampleTime, "was", point.absoluteTime)
                point.offsetTime = 0
                point.lastRenderTime = sampleTime
            }
        }
    }

    // probably not necessary, but clear out any already triggered points if they are in here
    private func removeOldAutomation() {
        self.automationPoints = self.automationPoints.filter { !$0.triggered }
    }

    // MARK: - public functions

    /// add a single automation point
    @objc public func addAutomationPoint(point: AKParameterAutomationPoint) {
        self.automationPoints.append(point)
        AKLog("+", point.value, "total points:", self.automationPoints.count)
    }

    /// starts up a render callback to trigger automation values
    @objc public func startAutomation() {
//        guard !automationEnabled else { return }
        self.validatePoints()
        self.automationEnabled = true
    }

    /// remove render callback and clear out automation points
    @objc public func stopAutomation() {
//        guard automationEnabled else { return }

        // AKLog("current points:", self.automationPoints)

        self.automationEnabled = false
        self.automationPoints.removeAll()
    }

    @objc public override func detach() {
        AKLog("self.selfPointer", self.selfPointer)

//        if self.automationEnabled, let audioUnit = avAudioUnit?.audioUnit {
//            if AudioUnitRemoveRenderNotify(audioUnit, renderCallback, self.selfPointer) != noErr {
//                AKLog("ERROR removing the renderNotify")
//            }
//        }

        self.automationEnabled = false

        self.selfPointer = nil
        super.detach()
    }

    @objc deinit {
        AKLog("* { AKAutomatedNode }")
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

// Swift Struct version
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

// as an objc object for compatibility
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

    var triggered: Bool = false

    open override var description: String {
        return "AKParameterAutomationPoint address \(self.address) value \(self.value) " +
            "offsetTime \(self.offsetTime) lastRenderTime \(self.lastRenderTime), absoluteTime \(self.absoluteTime) " +
            "rampDuration \(self.rampDuration) rampType \(self.rampType) triggered \(self.triggered)"
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

// MARK: - Render Callback used to make AudioUnitAddRenderNotify a bit friendlier

@objc protocol AURenderCallbackDelegate {
    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                       inTimeStamp: UnsafePointer<AudioTimeStamp>,
                       inBusNumber: UInt32,
                       inNumberFrames: UInt32,
                       ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
}

/// Global render callback that 'C' can see in:
/// AudioUnitAddRenderNotify, AudioUnitRemoveRenderNotify
func renderCallback(inRefCon: UnsafeMutableRawPointer,
                    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                    inTimeStamp: UnsafePointer<AudioTimeStamp>,
                    inBusNumber: UInt32,
                    inNumberFrames: UInt32,
                    ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    // this is kind of scary, like most C interop with Swift,
    // cast to the delegate rather than to self
    // let delegate = unsafeBitCast(inRefCon, to: AURenderCallbackDelegate.self)

    let delegate = Unmanaged<AURenderCallbackDelegate>.fromOpaque(inRefCon).takeUnretainedValue()

    return delegate.performRender(ioActionFlags: ioActionFlags,
                                  inTimeStamp: inTimeStamp,
                                  inBusNumber: inBusNumber,
                                  inNumberFrames: inNumberFrames,
                                  ioData: ioData)
}
