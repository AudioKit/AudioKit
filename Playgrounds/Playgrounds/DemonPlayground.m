//
//  DemonPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/17/15. (But it feels like Halloween!)
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface Demons : AKInstrument
@property AKInstrumentProperty *lowPitchShift;
@property AKInstrumentProperty *highPitchShift;
@property AKInstrumentProperty *highVoiceFeedback;
@end

@implementation Demons

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super initWithNumber:2];
    if (self) {

        _lowPitchShift  = [self createPropertyWithValue:0.7 minimum:0.5 maximum:1.0];
        _highPitchShift = [self createPropertyWithValue:2.0 minimum:1.0 maximum:5.0];
        _highVoiceFeedback = [self createPropertyWithValue:0.4 minimum:0.2 maximum:0.7];

        // Your basic pitch-lowered main Demon
        AKPitchShifter *lowVoice = [AKPitchShifter pitchShifterWithInput:input];
        lowVoice.frequencyRatio = _lowPitchShift;

        // Higher pitched mini-demons will have a pitch that varies
        AKVibrato *vibrato = [AKVibrato vibrato];
        vibrato.averageAmplitude = akp(0.1);
        vibrato.averageFrequency = akp(7);

        AKPitchShifter *highVoice = [AKPitchShifter pitchShifterWithInput:input];
        highVoice.frequencyRatio = [_highPitchShift plus:vibrato];

        AKDelay *feedbackDelay;
        feedbackDelay = [AKDelay delayWithInput:highVoice delayTime:akp(1)];
        feedbackDelay.feedback = _highVoiceFeedback;

        AKOscillator *panPosition = [AKOscillator oscillator];
        panPosition.frequency = akp(1);

        AKPanner *panner = [AKPanner pannerWithInput:feedbackDelay];
        panner.pan = panPosition;

        AKMix *mixLeft  = [[AKMix alloc] initWithInput1:lowVoice input2:panner.leftOutput balance:akp(0.5)];
        AKMix *mixRight = [[AKMix alloc] initWithInput1:lowVoice input2:panner.rightOutput balance:akp(0.5)];

        AKStereoAudio *stereoMix = [[AKStereoAudio alloc] initWithLeftAudio:mixLeft rightAudio:mixRight];

        AKReverb *reverb = [AKReverb presetLargeHallReverbWithStereoInput:stereoMix];

        AKMix *finalMixLeft  = [[AKMix alloc] initWithInput1:mixLeft  input2:reverb.leftOutput  balance:akp(0.4)];
        AKMix *finalMixRight = [[AKMix alloc] initWithInput1:mixRight input2:reverb.rightOutput balance:akp(0.4)];

        [self setAudioOutputWithLeftAudio:finalMixLeft rightAudio:finalMixRight];
        [self resetParameter:input];
    }
    return self;
}

@end

@implementation Playground

- (void)run
{
    [super run];

    AKMicrophone *mic = [[AKMicrophone alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    [mic restart];

    Demons *demons = [[Demons alloc] initWithInput:mic.output];
    [AKOrchestra addInstrument:demons];
    [demons restart];

    [self addSliderForProperty:demons.lowPitchShift title:@"Low Voice"];
    [self addSliderForProperty:demons.highPitchShift title:@"High Voice"];
    [self addSliderForProperty:demons.highVoiceFeedback title:@"High Voice Feedback"];

    [self addAudioOutputRollingWaveformPlot];
}

@end
