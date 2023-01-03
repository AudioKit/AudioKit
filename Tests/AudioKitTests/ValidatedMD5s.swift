import AVFoundation
import XCTest

extension URL {
    static var testAudio: URL {
        return Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
    }

    static var testAudioDrums: URL {
        return Bundle.module.url(forResource: "drumloop", withExtension: "wav", subdirectory: "TestResources")!
    }

}

extension XCTestCase {
    func testMD5(_ buffer: AVAudioPCMBuffer) {
        let localMD5 = buffer.md5
        let name = description
        XCTAssertFalse(buffer.isSilent)
        if let validMD5s = validatedMD5s[name] {
            XCTAssert(validMD5s.contains(localMD5), "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
        }
    }
}

let validatedMD5s: [String: [String]] = [
    "-[AppleSamplerTests testAmplitude]": ["d0526514c48f769f48e237974a21a2e5"],
    "-[AppleSamplerTests testPan]": ["6802732a1a3d132485509187fe476f9a"],
    "-[AppleSamplerTests testSamplePlayback]": ["7e38e34c8d052d9730b24cddd160d328"],
    "-[AppleSamplerTests testStop]": ["b42b86f6a7ff3a6fc85eb1760226cba0"],
    "-[AppleSamplerTests testVolume]": ["0b71c337205812fb30c536a014af7765"],
    "-[AudioPlayerTests testBasic]": ["feb1367cee8917a890088b8967b8d422"],
    "-[AudioPlayerTests testEngineRestart]": ["b0dd4297f40fd11a2b648f6cb3aad13f"],
    "-[AudioPlayerTests testCurrentTime]": ["af7c73c8c8c6f43a811401246c10cba4"],
    "-[AudioPlayerTests testToggleEditTime]": ["ff165ef8695946c41d3bbb8b68e5d295"],
    "-[AudioPlayerTests testLoop]": ["4288a0ae8722e446750e1e0b3b96068a"],
    "-[AudioPlayerTests testPlayAfterPause]": ["ff480a484c1995e69022d470d09e6747"],
    "-[AudioPlayerTests testScheduleFile]": ["ba487f42fa93379f0b24c7930d51fdd3"],
    "-[AudioPlayerTests testSeek]": ["3bba42419e6583797e166b7a6d4bb45d"],
    "-[AudioPlayerTests testVolume]": ["ba487f42fa93379f0b24c7930d51fdd3"],
    "-[AudioPlayerTests testSwitchFilesDuringPlayback]": ["5bd0d50c56837bfdac4d9881734d0f8e"],
    "-[AudioPlayerTests testCanStopPausedPlayback]": ["7076f63dc5c70f6bd006a7d4ff891aa3"],
    "-[AudioPlayerTests testCurrentPosition]": ["8c5c55d9f59f471ca1abb53672e3ffbf"],
    "-[AudioPlayerTests testSeekAfterPause]": ["271add78c1dc38d54b261d240dab100f"],
    "-[AudioPlayerTests testSeekAfterStop]": ["90a31285a6ce11a3609a2c52f0b3ec66"],
    "-[AudioPlayerTests testSeekForwardsAndBackwards]": ["31d6c565efa462738ac32e9438ccfed0"],
    "-[AudioPlayerTests testSeekWillStop]": ["84b026cbdf45d9c5f5659f1106fdee6a"],
    "-[AudioPlayerTests testSeekWillContinueLooping]": ["5becbd9530850f217f95ee1142a8db30"],
    "-[AudioPlayerTests testPlaybackWillStopWhenSettingLoopingForBuffer]": ["5becbd9530850f217f95ee1142a8db30"],
    "-[CompressorTests testAttackTime]": ["f2da585c3e9838c1a41f1a5f34c467d0"],
    "-[CompressorTests testDefault]": ["3064ef82b30c512b2f426562a2ef3448"],
    "-[CompressorTests testHeadRoom]": ["98ac5f20a433ba5a858c461aa090d81f"],
    "-[CompressorTests testMasterGain]": ["b8ff41f64341a786bd6533670d238560"],
    "-[CompressorTests testParameters]": ["6b99deb194dd53e8ceb6428924d6666b"],
    "-[CompressorTests testThreshold]": ["e1133fc525a256a72db31453d293c47c"],
    "-[MixerTests testSplitConnection]": ["6b2d34e86130813c7e7d9f1cf7a2a87c"],
    "-[MultiSegmentPlayerTests testAttemptToPlayZeroFrames]": ["feb1367cee8917a890088b8967b8d422"],
    "-[MultiSegmentPlayerTests testPlaySegment]": ["feb1367cee8917a890088b8967b8d422"],
    "-[MultiSegmentPlayerTests testPlaySegmentInTheFuture]": ["00545f274477d014dcc51822d97f1705"],
    "-[MultiSegmentPlayerTests testPlayMultipleSegments]": ["feb1367cee8917a890088b8967b8d422"],
    "-[MultiSegmentPlayerTests testPlayMultiplePlayersInSync]": ["d405ff00ef9dd3c890486163b7499a52"],
    "-[MultiSegmentPlayerTests testPlayWithinSegment]": ["adc3d1fef36f68e1f12dbb471eb4069b"],
    "-[NodeRecorderTests testBasicRecord]": ["f98d952748c408b1e38325f2bfe2ce81"],
    "-[NodeTests testDisconnect]": ["8c5c55d9f59f471ca1abb53672e3ffbf"],
    "-[NodeTests testDynamicConnection]": ["8c39c3c9a55e4a8675dc352da8543974"],
    "-[NodeTests testDynamicConnection2]": ["8c5c55d9f59f471ca1abb53672e3ffbf"],
    "-[NodeTests testDynamicConnection3]": ["70e6414b0f09f42f70ca7c0b0d576e84"],
    "-[NodeTests testDynamicOutput]": ["faf8254c11a6b73eb3238d57b1c14a9f"],
    "-[NodeTests testNodeBasic]": ["7e9104f6cbe53a0e3b8ec2d041f56396"],
    "-[NodeTests testNodeConnection]": ["5fbcf0b327308ff4fc9b42292986e2d5"],
    "-[NodeTests testNodeDetach]": ["8c5c55d9f59f471ca1abb53672e3ffbf"],
    "-[NodeTests testTwoEngines]": ["42b1eafdf0fc632f46230ad0497a29bf"],
    "-[PeakLimiterTests testAttackTime]": ["8e221adb58aca54c3ad94bce33be27db"],
    "-[PeakLimiterTests testDecayTime]": ["5f3ea74e9760271596919bf5a41c5fab"],
    "-[PeakLimiterTests testDecayTime2]": ["a2a33f30e573380bdacea55ea9ca2dae"],
    "-[PeakLimiterTests testDefault]": ["61c67b55ea69bad8be2bbfe5d5cde055"],
    "-[PeakLimiterTests testParameters]": ["e4abd97f9f0a0826823c167fb7ae730b"],
    "-[PeakLimiterTests testPreGain]": ["2f1b0dd9020be6b1fa5b8799741baa5f"],
    "-[PeakLimiterTests testPreGainChangingAfterEngineStarted]": ["ed14bc85f1732bd77feaa417c0c20cae"],
    "-[ReverbTests testBypass]": ["6b2d34e86130813c7e7d9f1cf7a2a87c"],
    "-[ReverbTests testCathedral]": ["7f1a07c82349bcd989a7838fd3f5ca9d"],
    "-[ReverbTests testDefault]": ["28d2cb7a5c1e369ca66efa8931d31d4d"],
    "-[ReverbTests testSmallRoom]": ["747641220002d1c968d62acb7bea552c"],
    "-[SequencerTrackTests testChangeTempo]": ["3e05405bead660d36ebc9080920a6c1e"],
    "-[SequencerTrackTests testLoop]": ["3a7ebced69ddc6669932f4ee48dabe2b"],
    "-[SequencerTrackTests testOneShot]": ["3fbf53f1139a831b3e1a284140c8a53c"],
    "-[SequencerTrackTests testTempo]": ["1eb7efc6ea54eafbe616dfa8e1a3ef36"],
    "-[TableTests testReverseSawtooth]": ["3c40428e755926307bffd903346dd652"],
    "-[TableTests testSawtooth]": ["f31d4c79fd6822e9e457eaaa888378a2"],
    "-[TableTests testTriangle]": ["9c1146981e940074bbbf63f1c2dd3896"],
    "-[EngineTests testBasic]": ["6869abdc57172524cae42e6dfe156717", "f5b785dcc74759b4a0492aef430bfc2e"],
    "-[EngineTests testCompressorWithSampler]": ["f2da585c3e9838c1a41f1a5f34c467d0"],
    "-[EngineTests testDynamicChange]": ["7844ad59f69ddb82bb3c929878e41691", "27bfee745a1ff33f8705f0c0746f61a4"],
    "-[EngineTests testEffect]": ["4a6c20066720f76eb7298b5e2c3de487", "87001076267eccfdeb864cfdef2aaed8"],
    "-[EngineTests testMixer]": ["3e5a8031aa91b780628c04c596f02a72", "3080c286b6a0afb4a236f9081b71305f"],
    "-[EngineTests testMixerDynamic]": ["3bec0f12d12bb148a76abc9a783638b8", "b769c079b3de2646072cdc1226278527"],
    "-[EngineTests testMixerVolume]": ["9ceefd8024a0b3f68afa6cd185931b86", "258811a4f3df7ed61659950c68ccbd3e"],
    "-[EngineTests testMultipleChanges]": ["2fd4428074d3bee04f04eddd5bcfb389", "6a7c75f86ded225279473587866eb454"],
    "-[EngineTests testPlaygroundOscillator]": ["6854112b8fcdcde5604ba57c69e685ec"],
    "-[EngineTests testSampler]": ["f44518ab94a8bab9a3ef8acfe1a4d45b"],
    "-[EngineTests testSamplerMIDINote]": ["38f84463320c0824422b4105b771b67c"],
    "-[EngineTests testTwoEffects]": ["4caf3fa63900e5091c8bbb8c2f40089f", "646e8387347deb4f5fbe3e24753b4543"],

]
