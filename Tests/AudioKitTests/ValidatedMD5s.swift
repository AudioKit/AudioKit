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
    "-[DynamicsProcessorTests testPreset]": ["f0c09e218767a2d11425688ba3b570c3"],
    "-[DynamicsProcessorTests testThreshold]": ["e1133fc525a256a72db31453d293c47c"],
    "-[MixerTests testSplitConnection]": ["6b2d34e86130813c7e7d9f1cf7a2a87c"],
    "-[NodeRecorderTests testBasicRecord]": ["f98d952748c408b1e38325f2bfe2ce81"],
    "-[NodeTests testDisconnect]": ["8c5c55d9f59f471ca1abb53672e3ffbf"],
    "-[NodeTests testDynamicConnection]": ["b812ee753c1bd5e76b9305a096e2562d", "53cec444033ef5f04b2f0d2114bf30eb"],
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
    "-[MatrixReverbTests testDefault]": ["353ce82b89b2f9c28fdd05773c5c2f0b"],
    "-[MatrixReverbTests testSmallRoom]": ["c205a155458107f22affd9ce1ec84c82"],
    "-[MatrixReverbTests testSmallLargeMix]": ["d392ce16d38c1419998574b22712a228"],
    "-[ReverbTests testBypass]": ["8105caf3748de8fcddf6766f85f8b59f"],
    "-[ReverbTests testCathedral]": ["8c45b6d97afb254830b94adf34d9ec0d"],
    "-[ReverbTests testDefault]": ["d0fea1c1fc888019c592586e318deb6e"],
    "-[ReverbTests testSmallRoom]": ["2a58159aa3f760b40d6f93ddbd1b8c45"],
    "-[TableTests testReverseSawtooth]": ["3c40428e755926307bffd903346dd652"],
    "-[TableTests testSawtooth]": ["f31d4c79fd6822e9e457eaaa888378a2"],
    "-[TableTests testSine]": ["87c195248adcd83ca41c50cf240504fb"],
    "-[TableTests testTriangle]": ["9c1146981e940074bbbf63f1c2dd3896"],
    "-[TableTests testHarmonicWithPartialAmplitudes]": ["dfa0ab73fb4135456e8702c8652b9ead"],
    "-[EngineTests testBasic]": ["96f75d59420c90eefa2a9f953902f358", "6325bd86b8fb3b6493fbe25da5f74fef"],
    "-[EngineTests testDynamicChange]": ["1366837b009efedbc445a4c963131b0b", "389f1fa836ed4101fbfcfb16a1a569cf"],
    "-[EngineTests testEffect]": ["4a45d6a3369c9fd3d1fb91833d73252a", "7f5623009e72f07c17ec489cfcf17715"],
    "-[EngineTests testMixer]": ["afd041d70949e88931a8b7ad802ac36f", "e7520e3efa548139a12cd8dda897fbac"],
    "-[EngineTests testMixerDynamic]": ["6126c43ac5eb4c1449adf354ad7f30e3", "0066e1a778b42ea9b079f3a67a0f81b8"],
    "-[EngineTests testMixerVolume]": ["e68370da71ed55059dfdebe3846bb864", "dcfc1a485706295b89096e443c208814"],
    "-[EngineTests testMultipleChanges]": ["d0ec5cb2d162a8519179e7d9a3eed524", "d5415f32cfb1fe8a63379d1d1196c1d1"],
    "-[EngineTests testOscillator]": ["b484df49b662f3bc1b41be9d5e3dcd23", "ec81679f6e9e4e476d96f0ae26c556be"],
    "-[EngineTests testSampler]": ["f44518ab94a8bab9a3ef8acfe1a4d45b"],
    "-[EngineTests testTwoEffects]": ["c1a6abd874e85a0c4721af2ad8f46f54", "910c00d933862b402663e64cf0ad6ebe"],
    "-[SamplerTests testSampler]": ["f44518ab94a8bab9a3ef8acfe1a4d45b"],
    "-[SamplerTests testSamplerMIDINote]": ["f44518ab94a8bab9a3ef8acfe1a4d45b"],
    "-[SamplerTests testDynamicsProcessorWithSampler]": ["3064ef82b30c512b2f426562a2ef3448"],
]
