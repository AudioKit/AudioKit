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

    func testSimpleAutomation() throws {

        let address = AUParameterAddress(42)
        let automationPoints = [ AKParameterAutomationPoint(targetValue: 880, startTime: 0, rampDuration: 1.0) ]

        var addresses:[AUParameterAddress] = []
        var values:[AUValue] = []

        let scheduleParameterBlock: AUScheduleParameterBlock = { (sampleTime, frameCount, address, value) in
            addresses.append(address)
            values.append(value)
        }

        let observer: AURenderObserver = automationPoints.withUnsafeBufferPointer { automationPtr in
            AKParameterAutomationGetRenderObserver(address,
                                                   scheduleParameterBlock,
                                                   44100,
                                                   0, // start time
                                                   1, // playback speed
                                                   automationPtr.baseAddress!,
                                                   automationPoints.count)
        }

        var timeStamp = AudioTimeStamp()
        timeStamp.mSampleTime = 0

        observer(.unitRenderAction_PreRender, &timeStamp, 256, 0)

        XCTAssertEqual(addresses, [9223372036854775850, 4611686018427387946, 2305843009213693994, 42])
        XCTAssertEqual(values, [1.0, 0.0, 0.0, 880.0])
    }

}
