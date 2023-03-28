// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

let validTestResults: [TestResult] = [
    TestResult(md5: "f26a2c57c43896381b16d3c3afcf5976", suiteName: "AppleSamplerTests", testName: "testAmplitude"),
    TestResult(md5: "f26a2c57c43896381b16d3c3afcf5976", suiteName: "AppleSamplerTests", testName: "testAmplitude"),
    TestResult(md5: "41ac3c9d92ecb63ecad5d7740be487a0", suiteName: "AppleSamplerTests", testName: "testPan"),
    TestResult(md5: "eeaea3cd4ff26b7d0df8f0002270c793", suiteName: "AppleSamplerTests", testName: "testSamplePlayback"),
    TestResult(md5: "b42b86f6a7ff3a6fc85eb1760226cba0", suiteName: "AppleSamplerTests", testName: "testStop"),
    TestResult(md5: "3a4d7f01a664fd08f65ba79497c2a6b4", suiteName: "AppleSamplerTests", testName: "testVolume"),
    TestResult(md5: "a13aea9dcf485589666db760e14241d3", suiteName: "AudioPlayerTests", testName: "testDefault"), // Apple
    TestResult(md5: "1e342477f88590fa315dee077ad07c71", suiteName: "AudioPlayerTests", testName: "testDefault"), // Intel
    TestResult(md5: "12a824fd71405fe90082df8a77f27122", suiteName: "AudioPlayerTests", testName: "testDefault"), // CI
    TestResult(md5: "1dbb38c415ca71d311695dc7bce4d327", suiteName: "AudioPlayerTests", testName: "testDefault"), // CI2
    TestResult(md5: "499386101282b71fd83785d8b5070a4f", suiteName: "AudioPlayerTests", testName: "testLoop"), // Apple
    TestResult(md5: "6f8d501184bfb07abbd4733a136f6444", suiteName: "AudioPlayerTests", testName: "testLoop"), // CI
    TestResult(md5: "481f7709e7a08a926112a256a5a6ced6", suiteName: "AudioPlayerTests", testName: "testPitch"), // Apple
    TestResult(md5: "1e24468fdc7b20c8ac8434db4e551fdb", suiteName: "AudioPlayerTests", testName: "testPitch"), // CI
    TestResult(md5: "d9192cd0c89539c9262c71bd4c3bedab", suiteName: "AudioPlayerTests", testName: "testPitch"), // Intel
    TestResult(md5: "576c1def2055593cd827aa3f1d6effde", suiteName: "AudioPlayerTests", testName: "testRate"), // Apple
    TestResult(md5: "103096c954ff23a2a841465225472d97", suiteName: "AudioPlayerTests", testName: "testRate"), // CI
    TestResult(md5: "71384a7974d944fbb030be20dcd826d7", suiteName: "AudioPlayerTests", testName: "testRate"), // Intel
    TestResult(md5: "609e0a3e3606082a92de70f733f37809", suiteName: "DistortionTests", testName: "testDefault"),
    TestResult(md5: "d54c5309e650d1e8291f3a8ee3423e61", suiteName: "DistortionTests", testName: "testPresetChange"),
    TestResult(md5: "f2da585c3e9838c1a41f1a5f34c467d0", suiteName: "DynamicsProcessorTests", testName: "testAttackTime"),
    TestResult(md5: "3064ef82b30c512b2f426562a2ef3448", suiteName: "DynamicsProcessorTests", testName: "testDefault"),
    TestResult(md5: "98ac5f20a433ba5a858c461aa090d81f", suiteName: "DynamicsProcessorTests", testName: "testHeadRoom"),
    TestResult(md5: "b8ff41f64341a786bd6533670d238560", suiteName: "DynamicsProcessorTests", testName: "testMasterGain"),
    TestResult(md5: "6b99deb194dd53e8ceb6428924d6666b", suiteName: "DynamicsProcessorTests", testName: "testParameters"),
    TestResult(md5: "f0c09e218767a2d11425688ba3b570c3", suiteName: "DynamicsProcessorTests", testName: "testPreset"),
    TestResult(md5: "e1133fc525a256a72db31453d293c47c", suiteName: "DynamicsProcessorTests", testName: "testThreshold"),
    TestResult(md5: "6b2d34e86130813c7e7d9f1cf7a2a87c", suiteName: "MixerTests", testName: "testSplitConnection"),
    TestResult(md5: "f98d952748c408b1e38325f2bfe2ce81", suiteName: "NodeRecorderTests", testName: "testBasicRecord"),
    TestResult(md5: "8c5c55d9f59f471ca1abb53672e3ffbf", suiteName: "NodeTests", testName: "testDisconnect"),
    TestResult(md5: "b812ee753c1bd5e76b9305a096e2562d", suiteName: "NodeTests", testName: "testDynamicConnection"), // Intel
    TestResult(md5: "53cec444033ef5f04b2f0d2114bf30eb", suiteName: "NodeTests", testName: "testDynamicConnection"), // Apple
    TestResult(md5: "8c5c55d9f59f471ca1abb53672e3ffbf", suiteName: "NodeTests", testName: "testDynamicConnection2"),
    TestResult(md5: "70e6414b0f09f42f70ca7c0b0d576e84", suiteName: "NodeTests", testName: "testDynamicConnection3"),
    TestResult(md5: "faf8254c11a6b73eb3238d57b1c14a9f", suiteName: "NodeTests", testName: "testDynamicOutput"),
    TestResult(md5: "7e9104f6cbe53a0e3b8ec2d041f56396", suiteName: "NodeTests", testName: "testNodeBasic"),
    TestResult(md5: "5fbcf0b327308ff4fc9b42292986e2d5", suiteName: "NodeTests", testName: "testNodeConnection"), // Intel
    TestResult(md5: "9ec058582f8c7db11bbd695071a04d4b", suiteName: "NodeTests", testName: "testNodeConnection"), // Apple
    TestResult(md5: "f3ef443b9db92b1662c9d305274db661", suiteName: "NodeTests", testName: "testNodeConnection"), // CI
    TestResult(md5: "8c5c55d9f59f471ca1abb53672e3ffbf", suiteName: "NodeTests", testName: "testNodeDetach"),
    TestResult(md5: "42b1eafdf0fc632f46230ad0497a29bf", suiteName: "NodeTests", testName: "testTwoEngines"),
    TestResult(md5: "8e221adb58aca54c3ad94bce33be27db", suiteName: "PeakLimiterTests", testName: "testAttackTime"),
    TestResult(md5: "5f3ea74e9760271596919bf5a41c5fab", suiteName: "PeakLimiterTests", testName: "testDecayTime"),
    TestResult(md5: "a2a33f30e573380bdacea55ea9ca2dae", suiteName: "PeakLimiterTests", testName: "testDecayTime2"),
    TestResult(md5: "61c67b55ea69bad8be2bbfe5d5cde055", suiteName: "PeakLimiterTests", testName: "testDefault"),
    TestResult(md5: "e4abd97f9f0a0826823c167fb7ae730b", suiteName: "PeakLimiterTests", testName: "testParameters"),
    TestResult(md5: "2f1b0dd9020be6b1fa5b8799741baa5f", suiteName: "PeakLimiterTests", testName: "testPreGain"),
    TestResult(md5: "ed14bc85f1732bd77feaa417c0c20cae", suiteName: "PeakLimiterTests", testName: "testPreGainChangingAfterEngineStarted"),
    TestResult(md5: "6b2d34e86130813c7e7d9f1cf7a2a87c", suiteName: "MatrixReverbTests", testName: "testBypass"),
    TestResult(md5: "3f8c5a1ada6a17b924ace7ba1268a20a", suiteName: "MatrixReverbTests", testName: "testCathedral"),
    TestResult(md5: "353ce82b89b2f9c28fdd05773c5c2f0b", suiteName: "MatrixReverbTests", testName: "testDefault"),
    TestResult(md5: "c205a155458107f22affd9ce1ec84c82", suiteName: "MatrixReverbTests", testName: "testSmallRoom"),
    TestResult(md5: "d392ce16d38c1419998574b22712a228", suiteName: "MatrixReverbTests", testName: "testSmallLargeMix"),
    TestResult(md5: "8105caf3748de8fcddf6766f85f8b59f", suiteName: "ReverbTests", testName: "testBypass"),
    TestResult(md5: "8c45b6d97afb254830b94adf34d9ec0d", suiteName: "ReverbTests", testName: "testCathedral"),
    TestResult(md5: "d0fea1c1fc888019c592586e318deb6e", suiteName: "ReverbTests", testName: "testDefault"),
    TestResult(md5: "2a58159aa3f760b40d6f93ddbd1b8c45", suiteName: "ReverbTests", testName: "testSmallRoom"),
    TestResult(md5: "3c40428e755926307bffd903346dd652", suiteName: "TableTests", testName: "testReverseSawtooth"),
    TestResult(md5: "f31d4c79fd6822e9e457eaaa888378a2", suiteName: "TableTests", testName: "testSawtooth"),
    TestResult(md5: "87c195248adcd83ca41c50cf240504fb", suiteName: "TableTests", testName: "testSine"),
    TestResult(md5: "9c1146981e940074bbbf63f1c2dd3896", suiteName: "TableTests", testName: "testTriangle"),
    TestResult(md5: "dfa0ab73fb4135456e8702c8652b9ead", suiteName: "TableTests", testName: "testHarmonicWithPartialAmplitudes"),
    TestResult(md5: "96f75d59420c90eefa2a9f953902f358", suiteName: "EngineTests", testName: "testBasic"), // Intel
    TestResult(md5: "6325bd86b8fb3b6493fbe25da5f74fef", suiteName: "EngineTests", testName: "testBasic"), // Apple
    TestResult(md5: "1366837b009efedbc445a4c963131b0b", suiteName: "EngineTests", testName: "testDynamicChange"), // Intel
    TestResult(md5: "389f1fa836ed4101fbfcfb16a1a569cf", suiteName: "EngineTests", testName: "testDynamicChange"), // Apple
    TestResult(md5: "4a45d6a3369c9fd3d1fb91833d73252a", suiteName: "EngineTests", testName: "testEffect"), // Intel
    TestResult(md5: "7f5623009e72f07c17ec489cfcf17715", suiteName: "EngineTests", testName: "testEffect"), // Apple
    TestResult(md5: "afd041d70949e88931a8b7ad802ac36f", suiteName: "EngineTests", testName: "testMixer"), // Intel
    TestResult(md5: "e7520e3efa548139a12cd8dda897fbac", suiteName: "EngineTests", testName: "testMixer"), // Apple
    TestResult(md5: "6126c43ac5eb4c1449adf354ad7f30e3", suiteName: "EngineTests", testName: "testMixerDynamic"), // Intel
    TestResult(md5: "0066e1a778b42ea9b079f3a67a0f81b8", suiteName: "EngineTests", testName: "testMixerDynamic"), // Apple
    TestResult(md5: "e68370da71ed55059dfdebe3846bb864", suiteName: "EngineTests", testName: "testMixerVolume"), // Intel
    TestResult(md5: "dcfc1a485706295b89096e443c208814", suiteName: "EngineTests", testName: "testMixerVolume"), // Apple
    TestResult(md5: "d0ec5cb2d162a8519179e7d9a3eed524", suiteName: "EngineTests", testName: "testMultipleChanges"), // Intel
    TestResult(md5: "d5415f32cfb1fe8a63379d1d1196c1d1", suiteName: "EngineTests", testName: "testMultipleChanges"), // Apple
    TestResult(md5: "b484df49b662f3bc1b41be9d5e3dcd23", suiteName: "EngineTests", testName: "testOscillator"), // Intel
    TestResult(md5: "ec81679f6e9e4e476d96f0ae26c556be", suiteName: "EngineTests", testName: "testOscillator"), // Apple
    TestResult(md5: "c1a6abd874e85a0c4721af2ad8f46f54", suiteName: "EngineTests", testName: "testTwoEffects"), // Intel
    TestResult(md5: "910c00d933862b402663e64cf0ad6ebe", suiteName: "EngineTests", testName: "testTwoEffects"), // Apple
    TestResult(md5: "f44518ab94a8bab9a3ef8acfe1a4d45b", suiteName: "SamplerTests", testName: "testSampler"),
    TestResult(md5: "f44518ab94a8bab9a3ef8acfe1a4d45b", suiteName: "SamplerTests", testName: "testPlayMIDINote"),
    TestResult(md5: "8c5c55d9f59f471ca1abb53672e3ffbf", suiteName: "SamplerTests", testName: "testStopMIDINote"),
    TestResult(md5: "3064ef82b30c512b2f426562a2ef3448", suiteName: "SamplerTests", testName: "testDynamicsProcessorWithSampler"),
]
