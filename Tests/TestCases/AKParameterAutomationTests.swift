//
//  AKParameterAutomationTests.swift
//  iOSTestSuiteTests
//
//  Created by Taylor Holliday on 7/16/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKParameterAutomationTests: XCTestCase {

    func observerTest(automation: [AKParameterAutomationPoint], sampleTime: Float64) -> ([AUParameterAddress], [AUValue]) {

        let address = AUParameterAddress(42)

        var addresses: [AUParameterAddress] = []
        var values: [AUValue] = []

        let scheduleParameterBlock: AUScheduleParameterBlock = { (sampleTime, frameCount, address, value) in
            addresses.append(address)
            values.append(value)
        }

        let observer: AURenderObserver = automation.withUnsafeBufferPointer { automationPtr in
            AKParameterAutomationGetRenderObserver(address,
                                                   scheduleParameterBlock,
                                                   44100,
                                                   0, // start time
                                                   1, // playback speed
                                                   automationPtr.baseAddress!,
                                                   automation.count)
        }

        var timeStamp = AudioTimeStamp()
        timeStamp.mSampleTime = sampleTime

        observer(.unitRenderAction_PreRender, &timeStamp, 256, 0)

        return (addresses, values)
    }

    func testSimpleAutomation() throws {

        let automationPoints = [ AKParameterAutomationPoint(targetValue: 880, startTime: 0, rampDuration: 1.0) ]

        let (addresses, values) = observerTest(automation: automationPoints, sampleTime: 0)

        // order is: taper, skew, offset, value
        XCTAssertEqual(addresses, [9223372036854775850, 4611686018427387946, 2305843009213693994, 42])
        XCTAssertEqual(values, [1.0, 0.0, 0.0, 880.0])
    }

    func testPastAutomation() {

        let automationPoints = [ AKParameterAutomationPoint(targetValue: 880, startTime: 0, rampDuration: 0.1) ]

        let (addresses, values) = observerTest(automation: automationPoints, sampleTime: 44100)

        // If the automation is in the past, the value should be set to the final value.
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [880.0])
    }

    func testPastAutomationTwo() {

        let automationPoints = [ AKParameterAutomationPoint(targetValue: 880, startTime: 0, rampDuration: 0.1),
                                 AKParameterAutomationPoint(targetValue: 440, startTime: 0.1, rampDuration: 0.1) ]

        let (addresses, values) = observerTest(automation: automationPoints, sampleTime: 44100)

        // If the automation is in the past, the value should be set to the final value.
        XCTAssertEqual(addresses, [42, 42])
        XCTAssertEqual(values, [880.0, 440.0])

    }

    func testFutureAutomation() {

        let automationPoints = [ AKParameterAutomationPoint(targetValue: 880, startTime: 1, rampDuration: 0.1) ]

        let (addresses, values) = observerTest(automation: automationPoints, sampleTime: 0)

        // If the automation is in the future, we should not get anything.
        XCTAssertEqual(addresses, [])
        XCTAssertEqual(values, [])
    }
}
