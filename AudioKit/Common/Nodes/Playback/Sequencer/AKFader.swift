//
//  AKFader.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/12/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public enum CurveType {
    case Linear, EqualPower, Exponential
    
    public static func fromString(curve: String) -> CurveType {
        
        switch curve {
        case "linear":
            return .Linear
        case "exponential":
            return .Exponential
        case "equalpower":
            return .EqualPower
        default:
            return .Linear
        }
    }
}

public class AKFader {
    
    let π = M_PI
    
    var output: AKBooster?
    
    var initialVolume: Double = 1.0 // make these only 0 or 1 right now
    var finalVolume: Double = 0.0   // make these only 0 or 1 right now
    
    var controlRate: Double = 1 / 30 // 30 times per second
    var curveType: CurveType = .Linear
    var curvature: Double = 0.5 // doesn't apply to linear
    var duration: Double = 1.0 // seconds
    var offset: Double = 0.0
    var stepCounter = 0
    var stepCount = 0
    
    var fadeTimer = NSTimer()
    var fadeScheduleTimer = NSTimer()
    
    /// Initialize the fader with a single control output
    public init(initialVolume: Double,
                finalVolume: Double,
                duration: Double = 1.0,
                type: CurveType = .Exponential,
                curvature: Double = 1.0,
                offset: Double = 0.0,
                output: AKBooster) {
        
        self.initialVolume = initialVolume
        self.finalVolume = finalVolume
        curveType = type
        self.curvature = curvature
        self.duration = duration
        self.offset = offset
        stepCount = Int(floor(duration / controlRate))
        self.output = output
    }
    
    /// Schedule a fade to start after fireTime
    ///
    /// - parameter fireTime: Time to start the fade at
    ///
    func scheduleFade(fireTime: Double) {
        
        fadeScheduleTimer = NSTimer.scheduledTimerWithTimeInterval(
            fireTime + offset,
            target: self,
            selector: #selector(scheduleFadeTimer),
            userInfo: nil,
            repeats: false)
        
        output!.gain = initialVolume
    }
    
    @objc func scheduleFadeTimer(timer: NSTimer) {
        startImmediately()
    }
    
    /// Start the fade WITH the offset
    public func start() {
        scheduleFade(0.0)
    }
    
    /// Start the fade WITHOUT the offset
    public func startImmediately() {
        stepCounter = 0
        
        if fadeTimer.valid {
            fadeTimer.invalidate()
        }
        fadeTimer = NSTimer.scheduledTimerWithTimeInterval(controlRate,
                                                           target: self,
                                                           selector: #selector(updateFade),
                                                           userInfo: nil,
                                                           repeats: true)
    }
    
    @objc func updateFade(timer: NSTimer) {
        let direction: Double = (initialVolume > finalVolume ? 1.0 : -1.0)
        
        if stepCount == 0 {
            endFade()
        } else if stepCounter <= stepCount {
            
            // normalized 0-1 value
            let controlAmount: Double = Double(stepCounter) / Double(stepCount)
            var scaledControlAmount: Double = 0.0
            
            switch curveType {
            case .Linear:
                scaledControlAmount = AKFader.denormalize(controlAmount,
                                                          minimum: initialVolume,
                                                          maximum: finalVolume,
                                                          taper: 1)
            case .Exponential:
                scaledControlAmount = AKFader.denormalize(controlAmount,
                                                          minimum: initialVolume,
                                                          maximum: finalVolume,
                                                          taper: curvature)
            case .EqualPower:
                //direction will be negative if going up
                scaledControlAmount = pow((0.5 + 0.5 * direction * cos(π * controlAmount)), 0.5)
            }
            
            output!.gain = scaledControlAmount
            stepCounter += 1
            
        } else {
            endFade()
        }
        
    }//end updateFade
    
    func endFade() {
        fadeTimer.invalidate()
        output!.gain = finalVolume
        stepCounter = 0
    }
    
    static func denormalize(input: Double,
                            minimum: Double,
                            maximum: Double,
                            taper: Double) -> Double {
        if taper > 0 {
            // algebraic taper
            return minimum + (maximum - minimum) * pow(input, taper)
        } else {
            // exponential taper
            var adjustedMinimum: Double = 0.0
            var adjustedMaximum: Double = 0.0
            if minimum == 0 { adjustedMinimum = 0.00000000001 }
            if maximum == 0 { adjustedMaximum = 0.00000000001 }
            return log(input / adjustedMinimum) / log(adjustedMaximum / adjustedMinimum) // not working right for 0 values
        }
    }
    
    static func generateCurvePoints(source: Double,
                                    target: Double,
                                    duration: Double = 1.0,
                                    type: CurveType = .Exponential,
                                    curvature: Double = 1.0,
                                    controlRate: Double = 1 / 30) -> [Double] {
        var curvePoints = [Double]()
        let stepCount = Int(floor(duration / controlRate))
        var counter = 0
        let direction: Double = source > target ? 1.0 : -1.0
        if counter <= stepCount {
            
            // normalized 0-1 value
            let controlAmount = Double(counter) / Double(stepCount)
            var scaledControlAmount: Double = 0.0
            
            switch type {
            case .Linear:
                scaledControlAmount = denormalize(controlAmount,
                                                  minimum: source,
                                                  maximum: target,
                                                  taper: 1)
            case .Exponential:
                scaledControlAmount = denormalize(controlAmount,
                                                  minimum: source,
                                                  maximum: target,
                                                  taper: curvature)
            case .EqualPower:
                //direction will be negative if going up
                scaledControlAmount = pow((0.5 + 0.5 * direction * cos(M_PI * controlAmount)), 0.5)
            }
            curvePoints.append(scaledControlAmount)
            counter += 1
        }
        return curvePoints
    }
}
