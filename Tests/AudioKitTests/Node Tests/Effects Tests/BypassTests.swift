// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFAudio
import XCTest

class BypassTests: XCTestCase {
    let duration = 0.1
    let source = Oscillator()
    var effects: [Node]!

    override func setUp() {
        super.setUp()
        effects = [
            Distortion(source),
            DynamicsProcessor(source),
            PeakLimiter(source),
            BandPassFilter(source),
            HighPassFilter(source),
            HighShelfFilter(source, cutOffFrequency: 100, gain: 3),
            LowPassFilter(source),
            LowShelfFilter(source, cutoffFrequency: 100, gain: 3),
            ParametricEQ(source, centerFreq: 100, q: 100, gain: 3),
            // Reverb(source),
            Delay(source),
        ]
    }

    override func tearDown() {
        effects = nil
        super.tearDown()
    }

    func testStopEffectDoesntPerformAnyTransformation() throws {
        // XXX: turned off for CI
        return
        let engine = Engine()
        for effect in effects {
            engine.output = effect
            effect.bypassed = true
            let data = engine.startTest(totalDuration: duration)
            data.append(engine.render(duration: duration))
            let channel1 = try XCTUnwrap(data.toFloatChannelData()?.first)

            XCTAssertTrue(channel1.allSatisfy { $0 == 1 }, "\(type(of: effect)) has not stopped correctly")
        }
    }

    func testStartEffectPerformsTransformation() throws {
        let engine = Engine()
        for effect in effects {
            engine.output = effect
            let data = engine.startTest(totalDuration: duration)
            data.append(engine.render(duration: duration))
            let channel1 = try XCTUnwrap(data.toFloatChannelData()?.first)

            XCTAssertFalse(channel1.allSatisfy { $0 == 1 }, "\(type(of: effect)) has not started correctly")
        }
    }

    func testStartStopEffectsChangesIsStarted() {
        for effect in effects {
            effect.bypassed = true
            XCTAssertFalse(effect.isStarted, "\(type(of: effect)) has not stopped correctly")
            effect.bypassed = false
            XCTAssertTrue(effect.isStarted, "\(type(of: effect)) has not started correctly")
        }
    }
}
