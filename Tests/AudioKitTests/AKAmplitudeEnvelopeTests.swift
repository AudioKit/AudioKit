// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKAmplitudeEnvelopeTests: AKTestCase {

    var envelope: AKAmplitudeEnvelope!

    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0
        afterStart = {
            self.input.play()
            self.envelope.start()
         }
    }

    func testAttack() {
        envelope = AKAmplitudeEnvelope(input, attackDuration: 0.123_4)
        engine.output = envelope
        AKTest()
    }

    func testDecay() {
        envelope = AKAmplitudeEnvelope(input, decayDuration: 0.234, sustainLevel: 0.345)
        engine.output = envelope
        AKTest()
    }

    func testDefault() {
        envelope = AKAmplitudeEnvelope(input)
        engine.output = envelope
        AKTest()
    }

    func testParameters() {
        envelope = AKAmplitudeEnvelope(input, attackDuration: 0.123_4, decayDuration: 0.234, sustainLevel: 0.345)
        engine.output = envelope
        AKTest()
    }

    func testSustain() {
        envelope = AKAmplitudeEnvelope(input, sustainLevel: 0.345)
        engine.output = envelope
        AKTest()
    }

    // Release is not tested at this time since there is no sample accurate way to define release point

}
