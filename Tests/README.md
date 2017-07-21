# Tests

[![Build Status](https://travis-ci.org/AudioKit/AudioKit.svg)](https://travis-ci.org/AudioKit/AudioKit)

We ensure all the included projects build by automatically testing them using Travis Continuous Integration.  We use unit tests to ensure that the nodes and operations in AudioKit work perfectly.  If a change is made to AudioKit to breaks something, we're automatically emailed.

Here are all the tests that run:

<pre>
AKAmplitudeEnvelopeTests
    ✓ testAttack
    ✓ testDecay
    ✓ testDefault
    ✓ testParameters
    ✓ testSustain

AKAutoWahTests
    ✓ testAmplitude
    ✓ testDefault
    ✓ testMix
    ✓ testParamters
    ✓ testWah

AKBandPassButterworthFilterTests
    ✓ testBandwidth
    ✓ testCenterFrequency
    ✓ testDefault
    ✓ testParameters

AKBandRejectButterworthFilterTests
    ✓ testBandwidth
    ✓ testCenterFrequency
    ✓ testDefault
    ✓ testParameters

AKBitCrusherTests
    ✓ testBitDepth
    ✓ testDefault
    ✓ testParameters
    ✓ testSampleRate

AKChowningReverbTests
    ✓ testActuallyProcessing
    ✓ testDefault

AKClipperTests
    ✓ testDefault
    ✓ testParameters1
    ✓ testParameters2

AKCompressorTests
    ✓ testAttackTime
    ✓ testDefault
    ✓ testHeadRoom
    ✓ testMasterGain
    ✓ testParameters
    ✓ testThreshold

AKCostelloReverbTests
    ✓ testCutoffFrequency
    ✓ testDefault
    ✓ testFeedback
    ✓ testParametersSetAfterInit
    ✓ testParametersSetOnInit

AKDCBlockTests
    ✓ testActuallyProcessing
    ✓ testDefault

AKDecimatorTests
    ✓ testDecimation
    ✓ testDefault
    ✓ testMix
    ✓ testParameters
    ✓ testRounding

AKDelayTests
    ✓ testDryWetMix
    ✓ testFeedback
    ✓ testLowpassCutoff
    ✓ testParameters
    ✓ testTime

AKDistortionTests
    ✓ testCubicTerm
    ✓ testDecay
    ✓ testDecimation
    ✓ testDecimationMix
    ✓ testDefault
    ✓ testDelay
    ✓ testDelayMix
    ✓ testFinalMix
    ✓ testLinearTerm
    ✓ testParameters
    ✓ testPolynomialMix
    ✓ testRingModBalance
    ✓ testRingModFreq1
    ✓ testRingModFreq2
    ✓ testRingModMix
    ✓ testRounding
    ✓ testSoftClipGain
    ✓ testSquaredTerm

AKDynamicRangeCompressorTests
    ✓ testAttackTime
    ✓ testDefault
    ✓ testParameters
    ✓ testRatio
    ✓ testReleaseTime
    ✓ testThreshold

AKDynamicsProcessorTests
    ✓ testDefault

AKEqualizerFilterTests
    ✓ testBandwidth
    ✓ testCenterFrequency
    ✓ testDefault
    ✓ testGain
    ✓ testParameters

AKExpanderTests
    ✓ testDefault

AKFMOscillatorBankTests
    ✓ testAttackDuration
    ✓ testCarrierMultiplier
    ✓ testDecayDuration
    ✓ testDefault
    ✓ testDetuningMultiplier
    ✓ testDetuningOffset
    ✓ testModulatingMultiplier
    ✓ testModulationIndex
    ✓ testParameters
    ✓ testSustainLevel
    ✓ testWaveform

AKFMOscillatorTests
    ✓ testDefault
    ✓ testParametersSetAfterInit
    ✓ testParametersSetOnInit
    ✓ testPresetBuzzer
    ✓ testPresetFogHorn
    ✓ testPresetSpiral
    ✓ testPresetStunRay
    ✓ testPresetWobble
    ✓ testSquareWave

AKFlatFrequencyResponseReverbTests
    ✓ testDefault
    ✓ testReverbDuration

AKFormantFilterTests
    ✓ testDefault

AKHighPassButterworthFilterTests
    ✓ testCutoffFrequency
    ✓ testDefault

AKHighPassFilterTests
    ✓ testCutoffFrequency
    ✓ testDefault
    ✓ testParameters
    ✓ testResonance

AKHighShelfFilterTests
    ✓ testDefault
    ✓ testGain
    ✓ testParameters

AKHighShelfParametricEqualizerFilterTests
    ✓ testCenterFrequency
    ✓ testDefault
    ✓ testGain
    ✓ testParameters
    ✓ testQ

AKKorgLowPassFilterTests
    ✓ testCutoffFrequency
    ✓ testDefault
    ✓ testParameters
    ✓ testResonance
    ✓ testSaturation

AKLowPassButterworthFilterTests
    ✓ testCutoffFrequency
    ✓ testDefault

AKLowPassFilterTests
    ✓ testCutoffFrequency
    ✓ testDefault
    ✓ testParameters
    ✓ testResonance

AKLowShelfFilterTests
    ✓ testCutoffFrequency
    ✓ testDefault
    ✓ testGain

AKLowShelfParametricEqualizerFilterTests
    ✓ testCornerFrequency
    ✓ testDefault
    ✓ testGain
    ✓ testParameters
    ✓ testQ

AKModalResonanceFilterTests
    ✓ testDefault
    ✓ testFrequency
    ✓ testParameters
    ✓ testQualityFactor

AKMoogLadderTests
    ✓ testCutoffFrequency
    ✓ testDefault
    ✓ testParameters
    ✓ testResonance

AKMorphingOscillatorBankTests
    ✓ testAttackDuration
    ✓ testDecayDuration
    ✓ testDefault
    ✓ testDetuningMultiplier
    ✓ testDetuningOffset
    ✓ testIndex
    ✓ testParameters
    ✓ testSustainLevel
    ✓ testWaveformArray

AKMorphingOscillatorTests
    ✓ testDefault
    ✓ testParametersSetAfterInit
    ✓ testParametersSetOnInit

AKOscillatorBankTests
    ✓ testAttackDuration
    ✓ testDecayDuration
    ✓ testDefault
    ✓ testDetuningMultiplier
    ✓ testParameters
    ✓ testSustainLevel
    ✓ testWaveform

AKOscillatorTests
    ✓ testParametersSetAfterInit
    ✓ testParametersSetOnInit

AKPWMOscillatorBankTests
    ✓ testAttackDuration
    ✓ testDecayDuration
    ✓ testDefault
    ✓ testDetuningMultiplier
    ✓ testDetuningOffset
    ✓ testParameters
    ✓ testPulseWidth
    ✓ testSustainLevel

AKPWMOscillatorTests
    ✓ testDefault
    ✓ testParametersSetAfterInit
    ✓ testParametersSetOnInit

AKPeakLimiterTests
    ✓ testAttackTime
    ✓ testDecayTime
    ✓ testDefault
    ✓ testParameters
    ✓ testPreGain

AKPeakingParametricEqualizerFilterTests
    ✓ testCenterFrequency
    ✓ testDefault
    ✓ testGain
    ✓ testParameters
    ✓ testQ

AKPhaseDistortionOscillatorBankTests
    ✓ testAttackDuration
    ✓ testDecayDuration
    ✓ testDefault
    ✓ testDetuningMultiplier
    ✓ testDetuningOffset
    ✓ testParameters
    ✓ testPhaseDistortion
    ✓ testSustainLevel
    ✓ testWaveform

AKPhaseDistortionOscillatorTests
    ✓ testDefault
    ✓ testParametersSetAfterInit
    ✓ testParametersSetOnInit

AKPinkNoiseTests
    ✓ testAmplitude
    ✓ testDefault

AKPitchShifterTests
    ✓ testCrossfade
    ✓ testDefault
    ✓ testParameters
    ✓ testShift
    ✓ testWindowSize

AKResonantFilterTests
    ✓ testBandwidth
    ✓ testDefault
    ✓ testFrequency
    ✓ testParameters

AKReverbTests
    ✓ testCathedral
    ✓ testDefault
    ✓ testSmallRoom

AKRingModulatorTests
    ✓ testDefault

AKRolandTB303FilterTests
    ✓ testCutoffFrequency
    ✓ testDefault
    ✓ testDistortion
    ✓ testParameters
    ✓ testResonance
    ✓ testResonanceAsymmetry

AKStringResonatorTests
    ✓ testBandwidth
    ✓ testDefault
    ✓ testFrequency
    ✓ testParameters

AKTableTests
    ✓ testReverseSawtooth
    ✓ testSawtooth
    ✓ testSine
    ✓ testTriangle

AKTanhDistortionTests
    ✓ testDefault
    ✓ testNegativeShapeParameter
    ✓ testParameters
    ✓ testPostgain
    ✓ testPostiveShapeParameter
    ✓ testPregain

AKThreePoleLowpassFilterTests
    ✓ testCutoffFrequency
    ✓ testDefault
    ✓ testDistortion
    ✓ testParameters
    ✓ testResonance

AKToneComplementFilterTests
    ✓ testDefault
    ✓ testHalfPowerPoint

AKToneFilterTests
    ✓ testDefault
    ✓ testHalfPowerPoint

AKTremoloTests
    ✓ testDefault
    ✓ testFrequency

AKVariableDelayTests
    ✓ testDefault
    ✓ testParametersSetAfterInit
    ✓ testParametersSetOnInit

AKWhiteNoiseTests
    ✓ testAmplitude
    ✓ testDefault

AKZitaReverbTests
    ✓ testDefault
    ✓ testParametersSetAfterInit
    ✓ testParametersSetOnInit

AutoWahTests
    ✓ testDefault

BitcrushTests
    ✓ testBitDepth
    ✓ testDefault
    ✓ testParameters
    ✓ testSampleRate

ClipTests
    ✓ testDefault

DCBlockTests
    ✓ testDefault

DelayTests
    ✓ testDefault

DistortTests
    ✓ testDefault

FMOscillatorTests
    ✓ testDefault
    ✓ testFMOscillatorOperation

HighPassButterworthFilterTests
    ✓ testDefault
HighPassFilterTests
    ✓ testDefault

KorgLowPassFilterTests
    ✓ testDefault
    ✓ testParameters

LowPassButterworthFilterTests
    ✓ testDefault

LowPassFilterTests
    ✓ testDefault

ModalResonanceFilterTests
    ✓ testDefault

MoogLadderFilterTests
    ✓ testDefault

MorphingOscillatorTests
    ✓ testDefault

PhasorTests
    ✓ testDefault

PinkNoiseTests
    ✓ testAmplitude
    ✓ testDefault
    ✓ testParameterSweep

PluckedStringTests
    ✓ testDefault

ResonantFilterTests
    ✓ testDefault

ReverberateWithChowningTests
    ✓ testDefault

ReverberateWithCombFilterTests
    ✓ testDefault

ReverberateWithCostelloTests
    ✓ testDefault

ReverberateWithFlatFrequencyResponseTests
    ✓ testDefault

SawtoothTests
    ✓ testDefault

SawtoothWaveTests
    ✓ testDefault

SineWaveTests
    ✓ testDefault

SmoothDelayTests
    ✓ testDefault

SquareTests
    ✓ testDefault

SquareWaveTests
    ✓ testDefault

StringResonatorTests
    ✓ testDefault

ThreePoleLowPassFilterTests
    ✓ testParameterSweep

TriangleTests
    ✓ testParameterSweep

TriangleWaveTests
    ✓ testParameterSweep

VariableDelayTests
    ✓ testParameterSweep

WhiteNoiseTests
    ✓ testAmplitude
    ✓ testDefault
    ✓ testParameterSweep

Executed 298 tests, with 0 failures (0 unexpected) in 5.504 (5.819) seconds
</pre>