// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit
import AVFoundation

class ParameterAutomationTests: XCTestCase {

    func observerTest(events: [AutomationEvent],
                      sampleTime: Float64,
                      startTime: Float = 0) -> ([AUParameterAddress], [AUValue], [AUAudioFrameCount]) {

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
            ParameterAutomationGetRenderObserver(address,
                                                 scheduleParameterBlock,
                                                 44100,
                                                 startTime,
                                                 automationPtr.baseAddress!,
                                                 events.count)
        }

        var timeStamp = AudioTimeStamp()
        timeStamp.mSampleTime = sampleTime

        observer(.unitRenderAction_PreRender, &timeStamp, 256, 0)

        return (addresses, values, durations)
    }

    func testSimpleAutomation() throws {

        let events = [ AutomationEvent(targetValue: 880, startTime: 0, rampDuration: 1.0) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 0)

        // order is: taper, skew, offset, value
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [880.0])
    }

    func testPastAutomation() {

        let events = [ AutomationEvent(targetValue: 880, startTime: 0, rampDuration: 0.1) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 44100)

        // If the automation is in the past, the value should be set to the final value.
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [880.0])
    }

    func testPastAutomationTwo() {

        let events = [ AutomationEvent(targetValue: 880, startTime: 0, rampDuration: 0.1),
                       AutomationEvent(targetValue: 440, startTime: 0.1, rampDuration: 0.1) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 44100)

        // If the automation is in the past, the value should be set to the final value.
        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [440.0])

    }

    func testFutureAutomation() {

        let events = [ AutomationEvent(targetValue: 880, startTime: 1, rampDuration: 0.1) ]

        let (addresses, values, _) = observerTest(events: events, sampleTime: 0)

        // If the automation is in the future, we should not get anything.
        XCTAssertEqual(addresses, [])
        XCTAssertEqual(values, [])
    }

    func testAutomationMiddle() {

        // Start automating in the middle of a segment.

        let events = [AutomationEvent(targetValue: 1, startTime: 0, rampDuration: 1.0)]

        let (addresses, values, durations) = observerTest(events: events, sampleTime: 128)

        XCTAssertEqual(addresses, [42])
        XCTAssertEqual(values, [1.0])
        XCTAssertEqual(durations, [UInt32(44100-128)])
    }

    func testRecord() {

        let engine = AudioEngine()

        let osc = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.0)
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

    func testDelayedAutomation() {
        let engine = AudioEngine()
        let osc = Oscillator(waveform: Table(.triangle))
        engine.output = osc
        osc.amplitude = 0.2
        osc.start()
        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))
        let events = [AutomationEvent(targetValue: 1320, startTime: 0, rampDuration: 0.1),
                      AutomationEvent(targetValue: 660, startTime: 0.1, rampDuration: 0.1),
                      AutomationEvent(targetValue: 1100, startTime: 0.2, rampDuration: 0.1),
                      AutomationEvent(targetValue: 770, startTime: 0.3, rampDuration: 0.1),
                      AutomationEvent(targetValue: 880, startTime: 0.4, rampDuration: 0.1)]
        osc.$frequency.automate(events: events)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
