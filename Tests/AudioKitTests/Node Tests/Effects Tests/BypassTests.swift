// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFAudio

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
class BypassTests: XCTestCase {
    let duration = 0.1
    let source = ConstantGenerator(constant: 1)
    var effects: [Node]!

    override func setUp() {
        super.setUp()
        effects = [
            Decimator(source),
            Distortion(source),
            RingModulator(source),
            Compressor(source),
            DynamicsProcessor(source),
            Expander(source),
            PeakLimiter(source),
            BandPassFilter(source),
            HighPassFilter(source),
            HighShelfFilter(source, cutOffFrequency: 100, gain: 3),
            LowPassFilter(source),
            LowShelfFilter(source, cutoffFrequency: 100, gain: 3),
            ParametricEQ(source, centerFreq: 100, q: 100, gain: 3),
            Reverb(source),
            Delay(source)
        ]
    }

    override func tearDown() {
        effects = nil
        super.tearDown()
    }

    func testStopEffectDoesntPerformAnyTransformation() throws {
        let engine = AudioEngine()
        for effect in effects {
            engine.output = effect

            effect.stop()
            let data = engine.startTest(totalDuration: duration)
            data.append(engine.render(duration: duration))
            let channel1 = try XCTUnwrap(data.toFloatChannelData()?.first)

            XCTAssertTrue(channel1.allSatisfy { $0 == 1 }, "\(type(of: effect)) has not stopped correctly")
        }
    }

    func testStartEffectPerformsTransformation() throws {
        let engine = AudioEngine()
        for effect in effects {
            engine.output = effect

            effect.start()
            let data = engine.startTest(totalDuration: duration)
            data.append(engine.render(duration: duration))
            let channel1 = try XCTUnwrap(data.toFloatChannelData()?.first)

            XCTAssertFalse(channel1.allSatisfy { $0 == 1 }, "\(type(of: effect)) has not started correctly")
        }
    }

    func testStartStopEffectsChangesIsStarted() {
        for effect in effects {
            effect.stop()
            XCTAssertFalse(effect.isStarted, "\(type(of: effect)) has not stopped correctly")
            effect.start()
            XCTAssertTrue(effect.isStarted, "\(type(of: effect)) has not started correctly")
        }
    }
}
