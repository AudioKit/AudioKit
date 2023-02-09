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
    "-[NodeTests testNodeConnection]": ["5fbcf0b327308ff4fc9b42292986e2d5", "9ec058582f8c7db11bbd695071a04d4b", "f3ef443b9db92b1662c9d305274db661"],
    "-[NodeTests testNodeDetach]": ["8c5c55d9f59f471ca1abb53672e3ffbf"],
    "-[NodeTests testTwoEngines]": ["42b1eafdf0fc632f46230ad0497a29bf"],
    "-[PeakLimiterTests testAttackTime]": ["8e221adb58aca54c3ad94bce33be27db"],
    "-[PeakLimiterTests testDecayTime]": ["5f3ea74e9760271596919bf5a41c5fab"],
    "-[PeakLimiterTests testDecayTime2]": ["a2a33f30e573380bdacea55ea9ca2dae"],
    "-[PeakLimiterTests testDefault]": ["61c67b55ea69bad8be2bbfe5d5cde055"],
    "-[PeakLimiterTests testParameters]": ["e4abd97f9f0a0826823c167fb7ae730b"],
    "-[PeakLimiterTests testPreGain]": ["2f1b0dd9020be6b1fa5b8799741baa5f"],
    "-[PeakLimiterTests testPreGainChangingAfterEngineStarted]": ["ed14bc85f1732bd77feaa417c0c20cae"],
    "-[MatrixReverbTests testBypass]": ["6b2d34e86130813c7e7d9f1cf7a2a87c"],
    "-[MatrixReverbTests testCathedral]": ["3f8c5a1ada6a17b924ace7ba1268a20a"],
    "-[MatrixReverbTests testDefault]": ["0b9059b2b45be5b68a68e1636d860dcd"],
    "-[MatrixReverbTests testSmallRoom]": ["c205a155458107f22affd9ce1ec84c82"],
    "-[ReverbTests testBypass]": ["8105caf3748de8fcddf6766f85f8b59f"],
    "-[ReverbTests testCathedral]": ["8c45b6d97afb254830b94adf34d9ec0d"],
    "-[ReverbTests testDefault]": ["d0fea1c1fc888019c592586e318deb6e"],
    "-[ReverbTests testSmallRoom]": ["2a58159aa3f760b40d6f93ddbd1b8c45"],
    "-[TableTests testReverseSawtooth]": ["3c40428e755926307bffd903346dd652"],
    "-[TableTests testSawtooth]": ["f31d4c79fd6822e9e457eaaa888378a2"],
    "-[TableTests testSine]": ["87c195248adcd83ca41c50cf240504fb"],
    "-[TableTests testTriangle]": ["9c1146981e940074bbbf63f1c2dd3896"],
    "-[TableTests testHarmonicWithPartialAmplitudes]": ["dfa0ab73fb4135456e8702c8652b9ead"],
    "-[EngineTests testBasic]": ["87c195248adcd83ca41c50cf240504fb", "434ec09c1e71d0bdef1a91c92a0d2c30"],
    "-[EngineTests testDynamicChange]": ["97fb2ad8c2cd078ab43e4a7fb47f0971", "08ccb09472af9a82fc1b6dbaf6c42c34"],
    "-[EngineTests testEffect]": ["a6aa462d1e77b569afa935e8f67f3e0a", "07c960c2544cac5603954f7725649c53"],
    "-[EngineTests testMixer]": ["9a14ac2edb9392b4da3e603475b4c050", "ca6ed06fe0b1c78ac14e59a31f1d1b82"],
    "-[EngineTests testMixerDynamic]": ["f1428ff0eaf4949f51790226c3d619dc", "e3da5e17710ba097542a6a24350eb616"],
    "-[EngineTests testMixerVolume]": ["025e920c34f50da04d03c8af3e21ac82", "9879c9ba8031408f754fff3210a5aa4a"],
    "-[EngineTests testMultipleChanges]": ["5f7d6a56abfd240629985f770f013a58", "88acaa1d85ecdf01fd1797b6026ee264"],
    "-[EngineTests testOscillator]": ["6854112b8fcdcde5604ba57c69e685ec", "15eb052f9415e0f90e447340bd609589"],
    "-[EngineTests testSampler]": ["f44518ab94a8bab9a3ef8acfe1a4d45b"],
    "-[EngineTests testSamplerMIDINote]": ["38f84463320c0824422b4105b771b67c"],
    "-[EngineTests testTwoEffects]": ["2e7c6944c22e6ce2de1ae11ffb5480c7", "d0b132c58adb5428bddce84d9127a700"],
    "-[SamplerTests testSampler]": ["f44518ab94a8bab9a3ef8acfe1a4d45b"],
    "-[SamplerTests testSamplerMIDINote]": ["38f84463320c0824422b4105b771b67c"],
    "-[SamplerTests testDynamicsProcessorWithSampler]": ["3064ef82b30c512b2f426562a2ef3448"],
]
