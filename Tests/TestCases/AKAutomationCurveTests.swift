//
//  AKAutomationCurveTests.swift
//  macOSTestSuiteTests
//
//  Created by Taylor Holliday on 7/29/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKAutomationCurveTests: AKTestCase {

    func testReplaceAutomation() {

        {
            let points = [ AKParameterAutomationPoint(targetValue: 440, startTime: 0, rampDuration: 0.1),
                           AKParameterAutomationPoint(targetValue: 880, startTime: 1, rampDuration: 0.1),
                           AKParameterAutomationPoint(targetValue: 440, startTime: 2, rampDuration: 0.1)]

            let events: [(Double, AUValue)] = [ (0.5, 100), (1.5, 200) ]

            let newPoints = AKReplaceAutomation(points: points,
                                                newPoints: events,
                                                startTime: 0.25,
                                                stopTime: 1.75)

            let expected = [ AKParameterAutomationPoint(targetValue: 440, startTime: 0, rampDuration: 0.1),
                             AKParameterAutomationPoint(targetValue: 100, startTime: 0.5, rampDuration: 0.01),
                             AKParameterAutomationPoint(targetValue: 200, startTime: 1.5, rampDuration: 0.01),
                             AKParameterAutomationPoint(targetValue: 440, startTime: 2, rampDuration: 0.1)]

            XCTAssertEqual(newPoints.count, 4)
            XCTAssertEqual(newPoints, expected)
        }();


        {
            let points = [ AKParameterAutomationPoint(targetValue: 440, startTime: 0, rampDuration: 0.1),
                           AKParameterAutomationPoint(targetValue: 880, startTime: 1, rampDuration: 0.1),
                           AKParameterAutomationPoint(targetValue: 440, startTime: 2, rampDuration: 0.1)]

            let events: [(Double, AUValue)] = [ ]

            let newPoints = AKReplaceAutomation(points: points,
                                                newPoints: events,
                                                startTime: 0,
                                                stopTime: 2)

            XCTAssertEqual(newPoints, [])
        }();

        {
            let points: [AKParameterAutomationPoint] = [ ]

            let events: [(Double, AUValue)] = [ (0.5, 100), (1.5, 200) ]

            let newPoints = AKReplaceAutomation(points: points,
                                                newPoints: events,
                                                startTime: 0,
                                                stopTime: 2)

            let expected = [ AKParameterAutomationPoint(targetValue: 100, startTime: 0.5, rampDuration: 0.01),
                             AKParameterAutomationPoint(targetValue: 200, startTime: 1.5, rampDuration: 0.01)]

            XCTAssertEqual(newPoints, expected)
        }()
    }

    func testEvaluateAutomationLinear() {
        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0)]

        let newPoints = AKEvaluateAutomation(initialValue: 0, points: points, resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0)
        XCTAssertEqual(newPoints[0].targetValue, 1)
        XCTAssertEqual(newPoints[0].rampDuration, 1)
    }


    func testEvaluateAutomationAlmostLinear() {

        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0, rampTaper: 1.0, rampSkew: 0.000001)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0.0)
        XCTAssert(fabs(newPoints[0].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(newPoints[1].startTime, 0.5)
        XCTAssertEqual(newPoints[1].targetValue, 1.0)
    }

    func testEvaluateAutomationSlightTaper() {

        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0, rampTaper: 1.00001, rampSkew: 0.0)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0.0)
        XCTAssert(fabs(newPoints[0].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(newPoints[1].startTime, 0.5)
        XCTAssertEqual(newPoints[1].targetValue, 1.0)
    }

    func testEvaluateAutomationCurved() {

        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0, rampTaper: 0.5, rampSkew: 0.1)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.1)

        XCTAssertEqual(newPoints.count, 10)

    }

    func testEvaluateAutomationTwoSegment() {

        // One linear, one curved segment.
        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 1.0),
                      AKParameterAutomationPoint(targetValue: 0, startTime: 1.0, rampDuration: 1.0, rampTaper: 1.0, rampSkew: 0.000001)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0.0)
        XCTAssertEqual(newPoints[0].targetValue, 1.0)

        XCTAssertEqual(newPoints[1].startTime, 1.0)
        XCTAssert(fabs(newPoints[1].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(newPoints[2].startTime, 1.5)
        XCTAssert(abs(newPoints[2].targetValue) < 0.0001)

    }

    func testEvaluateAutomationTwoSegment2() {

        // Curved segment cut off by linear segment.
        let points = [AKParameterAutomationPoint(targetValue: 1, startTime: 0, rampDuration: 2.0, rampTaper: 1.0, rampSkew: 0.000001),
                      AKParameterAutomationPoint(targetValue: 1, startTime: 1, rampDuration: 0.0)]

        let newPoints = AKEvaluateAutomation(initialValue: 0,
                                             points: points,
                                             resolution: 0.5)

        XCTAssertEqual(newPoints[0].startTime, 0.0)
        XCTAssertEqual(newPoints[0].rampDuration, 0.5)
        XCTAssertEqual(newPoints[0].targetValue, 0.25)

        XCTAssertEqual(newPoints[1].startTime, 0.5)
        XCTAssert(fabs(newPoints[1].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(newPoints[2].startTime, 1.0)
        XCTAssertEqual(newPoints[2].targetValue, 1.0)
        XCTAssertEqual(newPoints[2].rampDuration, 0.0)

    }

}
