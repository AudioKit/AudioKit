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
        } else {
            XCTFail("No MD5 for this test.")
        }
    }
}

let validatedMD5s: [String: [String]] = [
    "-[AppleSamplerTests testAmplitude]": ["f26a2c57c43896381b16d3c3afcf5976"],
    "-[AppleSamplerTests testPan]": ["41ac3c9d92ecb63ecad5d7740be487a0"],
    "-[AppleSamplerTests testSamplePlayback]": ["eeaea3cd4ff26b7d0df8f0002270c793"],
    "-[AppleSamplerTests testStop]": ["b42b86f6a7ff3a6fc85eb1760226cba0"],
    "-[AppleSamplerTests testVolume]": ["3a4d7f01a664fd08f65ba79497c2a6b4"],
    "-[DistortionTests testDefault]": ["609e0a3e3606082a92de70f733f37809"],
    "-[DistortionTests testPresetChange]": ["d54c5309e650d1e8291f3a8ee3423e61"],
    "-[DynamicsProcessorTests testAttackTime]": ["f2da585c3e9838c1a41f1a5f34c467d0"],
    "-[DynamicsProcessorTests testDefault]": ["3064ef82b30c512b2f426562a2ef3448"],
    "-[DynamicsProcessorTests testHeadRoom]": ["98ac5f20a433ba5a858c461aa090d81f"],
    "-[DynamicsProcessorTests testMasterGain]": ["b8ff41f64341a786bd6533670d238560"],
    "-[DynamicsProcessorTests testParameters]": ["6b99deb194dd53e8ceb6428924d6666b"],
    "-[DynamicsProcessorTests testThreshold]": ["e1133fc525a256a72db31453d293c47c"],
    "-[MixerTests testSplitConnection]": ["6b2d34e86130813c7e7d9f1cf7a2a87c"],
    "-[NodeRecorderTests testBasicRecord]": ["f98d952748c408b1e38325f2bfe2ce81"],
    "-[NodeTests testDisconnect]": ["8c5c55d9f59f471ca1abb53672e3ffbf"],
    "-[NodeTests testDynamicConnection]": ["8c39c3c9a55e4a8675dc352da8543974", "53cec444033ef5f04b2f0d2114bf30eb"],
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
    "-[TableTests testReverseSawtooth]": ["3c40428e755926307bffd903346dd652"],
    "-[TableTests testSawtooth]": ["f31d4c79fd6822e9e457eaaa888378a2"],
    "-[TableTests testSine]": ["87c195248adcd83ca41c50cf240504fb"],
    "-[TableTests testTriangle]": ["9c1146981e940074bbbf63f1c2dd3896"],
    "-[TableTests testHarmonicWithPartialAmplitudes]": ["dfa0ab73fb4135456e8702c8652b9ead"],
    "-[EngineTests testBasic]": ["6869abdc57172524cae42e6dfe156717", "f5b785dcc74759b4a0492aef430bfc2e"],
    "-[EngineTests testDynamicsProcessorWithSampler]": ["3064ef82b30c512b2f426562a2ef3448"],
    "-[EngineTests testDynamicChange]": ["082df3fc3dc0cadd731b05f817a8c2da", "27bfee745a1ff33f8705f0c0746f61a4"],
    "-[EngineTests testEffect]": ["91064f3f6112e22af8a8980b45e84c7d", "87001076267eccfdeb864cfdef2aaed8"],
    "-[EngineTests testMixer]": ["3e5a8031aa91b780628c04c596f02a72", "3080c286b6a0afb4a236f9081b71305f"],
    "-[EngineTests testMixerDynamic]": ["3bec0f12d12bb148a76abc9a783638b8", "b769c079b3de2646072cdc1226278527"],
    "-[EngineTests testMixerVolume]": ["9ceefd8024a0b3f68afa6cd185931b86", "258811a4f3df7ed61659950c68ccbd3e"],
    "-[EngineTests testMultipleChanges]": ["2fd4428074d3bee04f04eddd5bcfb389", "6a7c75f86ded225279473587866eb454"],
    "-[EngineTests testPlaygroundOscillator]": ["6854112b8fcdcde5604ba57c69e685ec", "15eb052f9415e0f90e447340bd609589"],
    "-[EngineTests testSampler]": ["f44518ab94a8bab9a3ef8acfe1a4d45b"],
    "-[EngineTests testSamplerMIDINote]": ["38f84463320c0824422b4105b771b67c"],
    "-[EngineTests testTwoEffects]": ["d2b8608a993c00c57c06824302c9a833", "646e8387347deb4f5fbe3e24753b4543"],

]
