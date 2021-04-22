// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit
import AVFoundation

class AutomationCurveTests: XCTestCase {

    typealias Point = ParameterAutomationPoint

    func testReplaceAutomationBasic() {
        let curve = AutomationCurve(points: [Point(targetValue: 440,
                                                   startTime: 0,
                                                   rampDuration: 0.1),
                                             Point(targetValue: 880,
                                                   startTime: 1,
                                                   rampDuration: 0.1),
                                             Point(targetValue: 440,
                                                   startTime: 2,
                                                   rampDuration: 0.1)])

        let events: [(Float, AUValue)] = [ (0.5, 100), (1.5, 200) ]

        let newCurve = curve.replace(range: 0.25 ... 1.75, withPoints: events)

        let expected = [ Point(targetValue: 440,
                               startTime: 0,
                               rampDuration: 0.1),
                         Point(targetValue: 100,
                               startTime: 0.5,
                               rampDuration: 0.01),
                         Point(targetValue: 200,
                               startTime: 1.5,
                               rampDuration: 0.01),
                         Point(targetValue: 440,
                               startTime: 2,
                               rampDuration: 0.1)]

        XCTAssertEqual(newCurve.points, expected)
    }

    func testReplaceAutomationErase() {
        let curve = AutomationCurve(points: [Point(targetValue: 440,
                                                   startTime: 0,
                                                   rampDuration: 0.1),
                                             Point(targetValue: 880,
                                                   startTime: 1,
                                                   rampDuration: 0.1),
                                             Point(targetValue: 440,
                                                   startTime: 2,
                                                   rampDuration: 0.1)])

        let events: [(Float, AUValue)] = [ ]

        let newCurve = curve.replace(range: 0 ... 2, withPoints: events)

        XCTAssertEqual(newCurve.points, [])
    }

    func testReplaceAutomationAdd() {
        let curve = AutomationCurve(points: [])

        let events: [(Float, AUValue)] = [ (0.5, 100), (1.5, 200) ]

        let newCurve = curve.replace(range: 0 ... 2, withPoints: events)

        let expected = [ Point(targetValue: 100,
                               startTime: 0.5,
                               rampDuration: 0.01),
                         Point(targetValue: 200,
                               startTime: 1.5,
                               rampDuration: 0.01)]

        XCTAssertEqual(newCurve.points, expected)
    }

    func testEvaluateAutomationLinear() {
        let curve = AutomationCurve(points: [Point(targetValue: 1,
                                                     startTime: 0,
                                                     rampDuration: 1.0)])

        let events = curve.evaluate(initialValue: 0, resolution: 0.5)

        XCTAssertEqual(events[0].startTime, 0)
        XCTAssertEqual(events[0].targetValue, 1)
        XCTAssertEqual(events[0].rampDuration, 1)
    }

    func testEvaluateAutomationAlmostLinear() {

        let curve = AutomationCurve(points: [Point(targetValue: 1,
                                                     startTime: 0,
                                                     rampDuration: 1.0,
                                                     rampTaper: 1.0,
                                                     rampSkew: 0.000001)])

        let events = curve.evaluate(initialValue: 0, resolution: 0.5)

        XCTAssertEqual(events[0].startTime, 0.0)
        XCTAssert(abs(events[0].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(events[1].startTime, 0.5)
        XCTAssertEqual(events[1].targetValue, 1.0)
    }

    func testEvaluateAutomationSlightTaper() {

        let curve = AutomationCurve(points: [Point(targetValue: 1,
                                                     startTime: 0,
                                                     rampDuration: 1.0,
                                                     rampTaper: 1.00001,
                                                     rampSkew: 0.0)])

        let events = curve.evaluate(initialValue: 0,
                                    resolution: 0.5)

        XCTAssertEqual(events[0].startTime, 0.0)
        XCTAssert(abs(events[0].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(events[1].startTime, 0.5)
        XCTAssertEqual(events[1].targetValue, 1.0)
    }

    func testEvaluateAutomationCurved() {

        let curve = AutomationCurve(points: [Point(targetValue: 1,
                                                     startTime: 0,
                                                     rampDuration: 1.0,
                                                     rampTaper: 0.5,
                                                     rampSkew: 0.1)])

        let events = curve.evaluate(initialValue: 0, resolution: 0.1)

        XCTAssertEqual(events.count, 10)

    }

    func testEvaluateAutomationTwoSegment() {

        // One linear, one curved segment.
        let curve = AutomationCurve(points: [Point(targetValue: 1,
                                                     startTime: 0,
                                                     rampDuration: 1.0),
                                               Point(targetValue: 0,
                                                     startTime: 1.0,
                                                     rampDuration: 1.0,
                                                     rampTaper: 1.0,
                                                     rampSkew: 0.000001)])

        let events = curve.evaluate(initialValue: 0, resolution: 0.5)

        XCTAssertEqual(events[0].startTime, 0.0)
        XCTAssertEqual(events[0].targetValue, 1.0)

        XCTAssertEqual(events[1].startTime, 1.0)
        XCTAssert(abs(events[1].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(events[2].startTime, 1.5)
        XCTAssert(abs(events[2].targetValue) < 0.0001)

    }

    func testEvaluateAutomationTwoSegment2() {

        // Curved segment cut off by linear segment.
        let curve = AutomationCurve(points: [Point(targetValue: 1,
                                                     startTime: 0,
                                                     rampDuration: 2.0,
                                                     rampTaper: 1.0,
                                                     rampSkew: 0.000001),
                                               Point(targetValue: 1,
                                                     startTime: 1,
                                                     rampDuration: 0.0)])

        let events = curve.evaluate(initialValue: 0, resolution: 0.5)

        XCTAssertEqual(events[0].startTime, 0.0)
        XCTAssertEqual(events[0].rampDuration, 0.5)
        XCTAssertEqual(events[0].targetValue, 0.25)

        XCTAssertEqual(events[1].startTime, 0.5)
        XCTAssert(abs(events[1].targetValue - 0.5) < 0.0001)

        XCTAssertEqual(events[2].startTime, 1.0)
        XCTAssertEqual(events[2].targetValue, 1.0)
        XCTAssertEqual(events[2].rampDuration, 0.0)

    }
    
        func testCombingSettingParameterWithRamping() {
            let engine = AudioEngine()
            let osc = Oscillator()
            osc.amplitude = 0.1
            engine.output = osc
            
            osc.frequency = 440.0
            osc.start()
        
            let audio = engine.startTest(totalDuration: 2.0)
            osc.$frequency.ramp(to: 880.0, duration: 1.0)
            audio.append(engine.render(duration: 1.0))
            osc.frequency = 440
            // osc.$frequency.ramp(to: 440.0, duration: 0.0)
            osc.$frequency.ramp(to: 660.0, duration: 1.0)
            audio.append(engine.render(duration: 1.0))
            // audio.audition()
            // testMD5(audio)
        }
}
