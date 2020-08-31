// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit
import AVFoundation

class AKParameterAutomationTests: XCTestCase {

    func observerTest(events: [AKAutomationEvent],
                      sampleTime: Float64,
                      startTime: Double = 0) -> ([AUParameterAddress], [AUValue], [AUAudioFrameCount]) {

        let address = AUParameterAddress(42)

        var addresses: [AUParameterAddress] = []
        var values: [AUValue] = []
        var durations: [AUAudioFrameCount] = []

        let scheduleParameterBlock: AUScheduleParameterBlock = { (sampleTime, rampDuration, address, value) in
            addresses.append(address)
            values.append(value)
            durations.append(rampDuration)
        }

        let observer: AURenderObserver = events.withUnsafeBufferPointer { automationPtr in
            AKParameterAutomationGetRenderObserver(address,
                                                   scheduleParameterBlock,
                                                   44100,
                                                   startTime, // start time
                                                   automationPtr.baseAddress!,
                                                   events.count)
        }

        var timeStamp = AudioTimeStamp()
        timeStamp.mSampleTime = sampleTime

        observer(.unitRenderAction_PreRender, &timeStamp, 256, 0)

        return (addresses, values, durations)
    }

    func testSimpleAutomation() throws {

        let events = [ AKAutomationEvent(targetValue: 880, startTime: 0, rampDuration: 1.0) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 0)

        // order is: taper, skew, offset, value
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [880.0])
    }

    func testPastAutomation() {

        let events = [ AKAutomationEvent(targetValue: 880, startTime: 0, rampDuration: 0.1) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 44100)

        // If the automation is in the past, the value should be set to the final value.
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [880.0])
    }

    func testPastAutomationTwo() {

        let events = [ AKAutomationEvent(targetValue: 880, startTime: 0, rampDuration: 0.1),
                       AKAutomationEvent(targetValue: 440, startTime: 0.1, rampDuration: 0.1) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 44100)

        // If the automation is in the past, the value should be set to the final value.
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [440.0])

    }

    func testFutureAutomation() {

        let events = [ AKAutomationEvent(targetValue: 880, startTime: 1, rampDuration: 0.1) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 0)

        // If the automation is in the future, we should not get anything.
        XCTAssertEqual(addresses, [])
        XCTAssertEqual(values, [])
    }

    func testAutomationMiddle() {

        // Start automating in the middle of a segment.

        let events = [AKAutomationEvent(targetValue: 1, startTime: 0, rampDuration: 1.0)]

        let (addresses, values, durations) = observerTest(events: events, sampleTime: 128)

        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [1.0])
        XCTAssertEqual(durations, [UInt32(44100-128)])
    }

    func testRecord() {

        let engine = AKEngine()

        let osc = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.0)
        engine.output = osc

        try! engine.start()
        osc.start()

        var values:[AUValue] = []

        osc.$frequency.recordAutomation { (event) in
            values.append(event.value)
        }

        RunLoop.main.run(until: Date().addingTimeInterval(1.0))

        osc.frequency = 800

        RunLoop.main.run(until: Date().addingTimeInterval(1.0))

        XCTAssertEqual(values, [800])

        osc.$frequency.stopRecording()

        osc.frequency = 500

        RunLoop.main.run(until: Date().addingTimeInterval(1.0))

        XCTAssertEqual(values, [800])
    }

}
