| Old Name | New Name | Notes |
|----------|----------|-------|
| ">>>(_:_:)" | - | This syntactical sugar for connecting nodes has been removed.  |
| AK3DPanner | - | This class was never tested and seemed to not work well.  |
| AKAbstractPlayer | - | This was a part of the AKPlayer. Use AudioPlayer instead. |
| AKADSRView | ADSRView |  |
| AKAmplitudeEnvelope  | AmplitudeEnvelope  |  |
| AKAmplitudeTap | AmplitudeTap |  |
| AKAmplitudeTracker | - | Use AmplitudeTap instead. |
| AKAppleSampler | AppleSampler |  |
| AKAppleSequencer | AppleSequencer |  |
| AKAudioFile | - | Everything has been updated to use Apple's AVAudioFile |
| AKAudioPlayer | AudioPlayer |  |
| AKAutoPanner | AutoPanner |  |
| AKAutoWah | AutoWah | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKBalancer | Balancer |  |
| AKBandPassButterworthFilter | BandPassButterworthFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKBandRejectButterworthFilter | BandRejectButterworthFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKBitCrusher | BitCrusher | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKBluetoothMIDIButton | BluetoothMIDIButton |  |
| AKBooster | Fader | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKBrownianNoise | BrownianNoise |  |
| AKButton | - | We have removed most of UI elements that were not specific to audio. |
| AKBypassButton | - |  |
| AKCallbackInstrument | CallbackInstrument |  |
| AKChorus | Chorus | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKChowningReverb | ChowningReverb | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKClarinet | Clarinet |  |
| AKClip | - |  |
| AKClipMerger | - |  |
| AKClipper | Clipper |  |
| AKClipPlayer | ClipPlayer |  |
| AKClipRecorder | ClipRecorder |  |
| AKCombFilterReverb | CombFilterReverb | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKComponent | AudioUnitContainer |  |
| AKCompressor | Compressor | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKComputedParameter | ComputedParameter |  |
| AKConvolution | Convolution | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKCostelloReverb | CostelloReverb | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKCustomUgen | - | Custom Ugen support has been removed from operations. |
| AKDCBlock | DCBlock | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKDecimator | Decimator | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKDelay | Delay | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKDevice | Device |  |
| AKDiskStreamer | - | This used a lot of AudioKit internals that were removed, but we'd love to port it to AudioKit 5 soon. |
| AKDistortion | Distortion | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKDrip | Drip |  |
| AKDryWetMixer | DryWetMixer |  |
| AKDuration | Duration |  |
| AKDynamicPlayer | - | This was a part of the AKPlayer. Use AudioPlayer instead. |
| AKDynamicRangeCompressor | DynamicRangeCompressor | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKDynamicsProcessor | DynamicsProcessor | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKDynaRageCompressor | DynaRageCompressor | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKEqualizerFilter | EqualizerFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKExpander | Expander | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKFader | Fader | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKFFTTap | FFTTap |  |
| AKFileClip | - |  |
| AKFileClipSequence | - |  |
| AKFlanger | Flanger | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKFlatFrequencyResponseReverb | FlatFrequencyResponseReverb |  |
| AKFlute | Flute |  |
| AKFMOscillator | FMOscillator |  |
| AKFMOscillatorBank | - | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKFMOscillatorFilterSynth | - | This used a lot of AudioKit internals that were removed, but we'd love to port it to AudioKit 5 soon. |
| AKFormantFilter | FormantFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKFrequencyTracker | - | Use a PitchTap instead.  |
| AKHighPassButterworthFilter | HighPassButterworthFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKHighPassFilter | HighPassFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKHighShelfFilter | HighShelfFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKHighShelfParametricEqualizerFilter | HighShelfParametricEqualizerFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKInput | - |  |
| AKKeyboardDelegate | KeyboardDelegate |  |
| AKKeyboardView | KeyboardView |  |
| AKKorgLowPassFilter | KorgLowPassFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKLog(fullname:file:line:_:) | Log(fullname:file:line:_:) |  |
| AKLowPassButterworthFilter | LowPassButterworthFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKLowPassFilter | LowPassFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKLowShelfFilter | LowShelfFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKLowShelfParametricEqualizerFilter | LowShelfParametricEqualizerFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKManager | - | This was a global singleton, instead create an instance of AudioEngine. |
| AKMandolin | MandolinString | This no longer simulataes for 4 sets of 2 strings, but rather just one string. Combine as necessary in your own code. |
| AKMetalBar | MetalBar |  |
| AKMetronome | - | Use a Sequencer with a metronome track instead.  |
| AKMicrophone | - | Use AudioEngine.InputNode, or engine.input.  |
| AKMicrophoneTracker | - | Use AmplitudeTap and Pitch Tap instead.  |
| AKMIDI | MIDI |  |
| AKMIDICallback | MIDICallback |  |
| AKMIDICallbackInstrument | MIDICallbackInstrument |  |
| AKMIDIClockListener | MIDIClockListener |  |
| AKMIDIControl | MIDIControl |  |
| AKMIDIEvent | MIDIEvent |  |
| AKMIDIFile | MIDIFile |  |
| AKMIDIFileChunkEvent | MIDIFileChunkEvent |  |
| AKMIDIFileTrack | MIDIFileTrack |  |
| AKMIDIInstrument | MIDIInstrument |  |
| AKMIDIListener | MIDIListener |  |
| AKMIDIMetaEvent | MIDIMetaEvent |  |
| AKMIDIMetaEventType | MIDIMetaEventType |  |
| AKMIDIMonoPolyListener | MIDIMonoPolyListener |  |
| AKMIDINode | MIDINode |  |
| AKMIDINoteData | MIDINoteData |  |
| AKMIDIOMNIListener | MIDIOMNIListener |  |
| AKMIDISampler | MIDISampler |  |
| AKMIDIStatus | MIDIStatus |  |
| AKMIDIStatusType | MIDIStatusType |  |
| AKMIDISystemCommand | MIDISystemCommand |  |
| AKMIDISystemCommandType | MIDISystemCommandType |  |
| AKMIDISystemRealTimeListener | MIDISystemRealTimeListener |  |
| AKMIDITempoListener | MIDITempoListener |  |
| AKMIDITimeOut | MIDITimeOut |  |
| AKMIDITransformer | MIDITransformer |  |
| AKMixer | Mixer | Mixer now has addInput and removeInput which can be used to dynamically change the signal chain while the engine is running. |
| AKModalResonanceFilter | ModalResonanceFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKMoogLadder | MoogLadder | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKMorphingOscillator | MorphingOscillator |  |
| AKMorphingOscillatorBank | - | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKMorphingOscillatorFilterSynth | - | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKMusicTrack | MusicTrackManager |  |
| AKNode | Node |  |
| AKNodeFFTPlot | NodeFFTPlot |  |
| AKNodeOutputPlot | NodeOutputPlot |  |
| AKNodeRecorder | NodeRecorder |  |
| AKOperation | Operation |  |
| AKOperationEffect | OperationEffect |  |
| AKOperationGenerator | OperationGenerator |  |
| AKOscillator | Oscillator |  |
| AKOscillatorBank | - | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKOscillatorFilterSynth | - | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKOutput | - |  |
| AKOutputWaveformPlot | - | Use a plot attached to a node. |
| AKPanner | Panner |  |
| AKParameter | Parameter |  |
| AKPeakingParametricEqualizerFilter | PeakingParametricEqualizerFilter |  |
| AKPeakLimiter | PeakLimiter |  |
| AKPeriodicFunction | - | Can use a Callback Loop or a Timer instead. |
| AKPhaseDistortionOscillator | PhaseDistortionOscillator |  |
| AKPhaseDistortionOscillatorBank | - | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKPhaseDistortionOscillatorFilterSynth | - | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKPhaseLockedVocoder | PhaseLockedVocoder | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKPhaser | Phaser | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKPinkNoise | PinkNoise |  |
| AKPitchShifter | PitchShifter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKPlayer | AudioPlayer | AudioPlayer is a major simplification of AKPlayer and is currently much more restrictive on what you can do with it. |
| AKPlaygroundLoop | CallbackLoop |  |
| AKPlaygroundView | - | We have removed most of UI elements that were not specific to audio. |
| AKPluckedString | PluckedString |  |
| AKPolyphonic | Polyphonic |  |
| AKPolyphonicNode | PolyphonicNode |  |
| AKPresetLoaderView | - | We have removed most of UI elements that were not specific to audio. |
| AKPropertySlider | - | We have removed most of UI elements that were not specific to audio. |
| AKPWMOscillator | PWMOscillator |  |
| AKPWMOscillatorBank | - | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKPWMOscillatorFilterSynth | - | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKRawMIDIPacket | RawMIDIPacket |  |
| AKRecordingResult | - |  |
| AKResonantFilter | ResonantFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKResourcesAudioFileLoaderView | - | We have removed most of UI elements that were not specific to audio. |
| AKReverb | Reverb | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKReverb2 | Reverb2 | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKRhinoGuitarProcessor | RhinoGuitarProcessor |  All effects need an input. ie. no more empty initialzers with connections defined later.|
| AKRhodesPiano | RhodesPiano |  |
| AKRingModulator | RingModulator | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKRolandTB303Filter | RolandTB303Filter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKRollingOutputPlot | - | Use a plot attached to a node. |
| AKSamplePlayer | SamplePlayer |  |
| AKSampler | Sampler |  |
| AKSequencer | Sequencer |  |
| AKSequencerTrack | SequencerTrack |  |
| AKSettings | Settings |  |
| AKShaker | Shaker |  |
| AKShakerType | ShakerType |  |
| AKStepper | - | We have removed most of UI elements that were not specific to audio. |
| AKStereoDelay | StereoDelay |  |
| AKStereoFieldLimiter | StereoFieldLimiter |  |
| AKStereoInput | StereoInput |  |
| AKStereoOperation | StereoOperation |  |
| AKStringResonator | StringResonator | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKSynth | Synth |  |
| AKSynthKick | SynthKick |  |
| AKSynthSnare | SynthSnare |  |
| AKTable | Table |  |
| AKTableType | TableType |  |
| AKTanhDistortion | TanhDistortion | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKTelephoneView | - | We have removed most of UI elements that were not specific to audio. |
| AKTester | - | AudioEngine now has the testing functionality |
| AKThreePoleLowpassFilter | ThreePoleLowpassFilter |  |
| AKTimePitch | TimePitch | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKTiming | - |  |
| AKToggleable | Toggleable |  |
| AKToneComplementFilter | ToneComplementFilter | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKToneFilter | ToneFilter | All effects need an input. ie. no more empty initialzers with connections defined later.  |
| AKTremolo | Tremolo |  |
| AKTry(_:) | ExceptionCatcher(_:) |  |
| AKTubularBells | TubularBells |  |
| AKTuningTable | TuningTable |  |
| AKTuningTableBase | TuningTableBase |  |
| AKTuningTableDelta12ET | TuningTableDelta12ET |  |
| AKTuningTableETNN | TuningTableETNN |  |
| AKVariableDelay | VariableDelay | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKVariSpeed | VariSpeed | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AKVocalTract | VocalTract |  |
| AKWaveTable | - | This used a lot of AudioKit internals that were removed, but we'd love to port it to AudioKit 5 soon. |
| AKWhiteNoise | WhiteNoise |  |
| AKZitaReverb | ZitaReverb | All effects need an input. ie. no more empty initialzers with connections defined later. |
| AudioKit | - | This was a global singleton, instead create an instance of AudioEngine. |
| ClipMergeDelegate | - |  |
| ClipMergerError | - |  |
| ClipRecordingError | - |  |
| FileClip | - |  |
| MultitouchGestureRecognizer | MultitouchGestureRecognizer |  |
| random(_:_:) | - | Use AUValue's random(in:) method. |

