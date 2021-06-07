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
    "-[AppleSamplerTests testAmplitude]": "d0526514c48f769f48e237974a21a2e5",
    "-[AppleSamplerTests testPan]": "6802732a1a3d132485509187fe476f9a",
    "-[AppleSamplerTests testSamplePlayback]": "7e38e34c8d052d9730b24cddd160d328",
    "-[AppleSamplerTests testStop]": "b42b86f6a7ff3a6fc85eb1760226cba0",
    "-[AppleSamplerTests testVolume]": "0b71c337205812fb30c536a014af7765",
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
    "-[MixerTests testSplitConnection]": "6b2d34e86130813c7e7d9f1cf7a2a87c",
    "-[NodeTests testAutomationAfterDelayedConnection]": "f5f2cf536578d5a037c88d2cd458eb10",
    "-[NodeTests testDisconnect]": "8c5c55d9f59f471ca1abb53672e3ffbf",
    "-[NodeTests testDynamicConnection]": "c61c69779df208d80f371881346635ce",
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
    "-[SequencerTrackTests testChangeTempo]": "3e05405bead660d36ebc9080920a6c1e",
    "-[SequencerTrackTests testLoop]": "3a7ebced69ddc6669932f4ee48dabe2b",
    "-[SequencerTrackTests testOneShot]": "3fbf53f1139a831b3e1a284140c8a53c",
    "-[SequencerTrackTests testTempo]": "1eb7efc6ea54eafbe616dfa8e1a3ef36",
    "-[TableTests testReverseSawtooth]": "b3188781c2e696f065629e2a86ef57a6",
    "-[TableTests testSawtooth]": "6f37a4d0df529995d7ff783053ff18fe",
    "-[TableTests testTriangle]": "789c1e77803a4f9d10063eb60ca03cea",
]
