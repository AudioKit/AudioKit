import AVFoundation
import XCTest

extension XCTestCase {
    func testMD5(_ buffer: AVAudioPCMBuffer) {
        let localMD5 = buffer.md5
        let name = self.description
        XCTAssertFalse(buffer.isSilent)
        XCTAssert(validatedMD5s[name] == buffer.md5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }
}

let validatedMD5s: [String: String] = [
    "-[AmplitudeTapTests testDefault]": "e732ff601fd8b47b3bdb6c4aa65cb7f1",
    "-[AmplitudeTapTests testLeftStereoMode]": "e732ff601fd8b47b3bdb6c4aa65cb7f1",
    "-[AmplitudeTapTests testPeakAnalysisMode]": "e732ff601fd8b47b3bdb6c4aa65cb7f1",
    "-[AmplitudeTapTests testRightStereoMode]": "e732ff601fd8b47b3bdb6c4aa65cb7f1",
    "-[AudioPlayerTests testBasic]": "feb1367cee8917a890088b8967b8d422",
    "-[AudioPlayerTests testEngineRestart]": "b0dd4297f40fd11a2b648f6cb3aad13f",
    "-[AudioPlayerTests testGetCurrentTime]": "af7c73c8c8c6f43a811401246c10cba4",
    "-[AudioPlayerTests testLoop]": "4288a0ae8722e446750e1e0b3b96068a",
    "-[AudioPlayerTests testPlayAfterPause]": "ff480a484c1995e69022d470d09e6747",
    "-[AudioPlayerTests testScheduleFile]": "ba487f42fa93379f0b24c7930d51fdd3",
    "-[AudioPlayerTests testSeek]": "3bba42419e6583797e166b7a6d4bb45d",
    "-[AudioPlayerTests testVolume]": "ba487f42fa93379f0b24c7930d51fdd3",
    "-[CompressorTests testAttackTime]": "f2da585c3e9838c1a41f1a5f34c467d0",
    "-[CompressorTests testDefault]": "3064ef82b30c512b2f426562a2ef3448",
    "-[CompressorTests testHeadRoom]": "98ac5f20a433ba5a858c461aa090d81f",
    "-[CompressorTests testMasterGain]": "b8ff41f64341a786bd6533670d238560",
    "-[CompressorTests testParameters]": "6b99deb194dd53e8ceb6428924d6666b",
    "-[CompressorTests testThreshold]": "e1133fc525a256a72db31453d293c47c",
    "-[FFTTapTests testBasic]": "68d1550a306b253f9d4c18cda0824d3a",
    "-[FFTTapTests testWithoutNormalization]": "68d1550a306b253f9d4c18cda0824d3a",
    "-[FFTTapTests testWithZeroPadding]": "68d1550a306b253f9d4c18cda0824d3a",
    "-[FaderTests testBypass]": "6b2d34e86130813c7e7d9f1cf7a2a87c",
    "-[FaderTests testDefault]": "6b2d34e86130813c7e7d9f1cf7a2a87c",
    "-[FaderTests testGain]": "a26597484ed5afc96d5db12d63b6a34b",
    "-[FaderTests testMany]": "6b2d34e86130813c7e7d9f1cf7a2a87c",
    "-[FaderTests testParameters]": "aae4e6e743cb9501e57b3761937d1e36",
    "-[FaderTests testParameters2]": "a26597484ed5afc96d5db12d63b6a34b",
    "-[NodeTests testAutomationAfterDelayedConnection]": "f5f2cf536578d5a037c88d2cd458eb10",
    "-[NodeTests testDisconnect]": "8c5c55d9f59f471ca1abb53672e3ffbf",
    "-[NodeTests testDynamicConnection]": "08bdb8c6f9bad4a7514d6619cf9c3af5",
    "-[NodeTests testDynamicConnection2]": "8c5c55d9f59f471ca1abb53672e3ffbf",
    "-[NodeTests testDynamicConnection3]": "70e6414b0f09f42f70ca7c0b0d576e84",
    "-[NodeTests testDynamicOutput]": "faf8254c11a6b73eb3238d57b1c14a9f",
    "-[NodeTests testNodeBasic]": "7e9104f6cbe53a0e3b8ec2d041f56396",
    "-[NodeTests testNodeConnection]": "5fbcf0b327308ff4fc9b42292986e2d5",
    "-[NodeTests testNodeDetach]": "8c5c55d9f59f471ca1abb53672e3ffbf",
    "-[NodeTests testTwoEngines]": "42b1eafdf0fc632f46230ad0497a29bf",
    "-[ParameterAutomationTests testDelayedAutomation]": "b4c68d2afd4fdbb5074b7ddc655ea5c6",
    "-[PeakLimiterTests testAttackTime]": "8e221adb58aca54c3ad94bce33be27db",
    "-[PeakLimiterTests testDecayTime]": "61c67b55ea69bad8be2bbfe5d5cde055",
    "-[PeakLimiterTests testDefault]": "61c67b55ea69bad8be2bbfe5d5cde055",
    "-[PeakLimiterTests testParameters]": "e4abd97f9f0a0826823c167fb7ae730b",
    "-[PeakLimiterTests testPreGain]": "2f1b0dd9020be6b1fa5b8799741baa5f",
    "-[SamplerTests testSampler]": "c37cb5398f1c3e74a9d77d24bbb50d51",
    "-[SequencerTrackTests testChangeTempo]": "9b6ae1c5739c5c6cec623dd4d5be3907",
    "-[SequencerTrackTests testLoop]": "067ebe8a9f345ec0df7d6d94428563db",
    "-[SequencerTrackTests testOneShot]": "a125d07a2023bd56b8e0e88d9b18c1ce",
    "-[SequencerTrackTests testTempo]": "2a1ecd4f6ac9d9c72230971ab5abe63c",
    "-[SynthTests testChord]": "155d8175419836512ead0794f551c7a0",
    "-[SynthTests testMonophonicPlayback]": "77fb882efcaf29c3a426036d85d04090",
    "-[SynthTests testParameterInitialization]": "e27794e7055b8ebdbf7d0591e980484e",
    "-[TableTests testReverseSawtooth]": "b3188781c2e696f065629e2a86ef57a6",
    "-[TableTests testSawtooth]": "6f37a4d0df529995d7ff783053ff18fe",
    "-[TableTests testTriangle]": "789c1e77803a4f9d10063eb60ca03cea",

]
