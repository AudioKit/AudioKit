//
//  AKZitaReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKZitaReverbAudioUnit.h"
#import "AKZitaReverbDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKZitaReverbAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKZitaReverbDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setDelay:(float)delay {
    _kernel.setDelay(delay);
}
- (void)setCrossoverFrequency:(float)crossoverFrequency {
    _kernel.setCrossoverFrequency(crossoverFrequency);
}
- (void)setLowReleaseTime:(float)lowReleaseTime {
    _kernel.setLowReleaseTime(lowReleaseTime);
}
- (void)setMidReleaseTime:(float)midReleaseTime {
    _kernel.setMidReleaseTime(midReleaseTime);
}
- (void)setDampingFrequency:(float)dampingFrequency {
    _kernel.setDampingFrequency(dampingFrequency);
}
- (void)setEqualizerFrequency1:(float)equalizerFrequency1 {
    _kernel.setEqualizerFrequency1(equalizerFrequency1);
}
- (void)setEqualizerLevel1:(float)equalizerLevel1 {
    _kernel.setEqualizerLevel1(equalizerLevel1);
}
- (void)setEqualizerFrequency2:(float)equalizerFrequency2 {
    _kernel.setEqualizerFrequency2(equalizerFrequency2);
}
- (void)setEqualizerLevel2:(float)equalizerLevel2 {
    _kernel.setEqualizerLevel2(equalizerLevel2);
}
- (void)setDryWetMix:(float)dryWetMix {
    _kernel.setDryWetMix(dryWetMix);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(ZitaReverb)

    // Create a parameter object for the delay.
    AUParameter *delayAUParameter =
    [AUParameter parameter:@"delay"
                      name:@"Delay in ms before reverberation begins."
                   address:delayAddress
                       min:0.0
                       max:200.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the crossoverFrequency.
    AUParameter *crossoverFrequencyAUParameter =
    [AUParameter parameter:@"crossoverFrequency"
                      name:@"Crossover frequency separating low and middle frequencies (Hz)."
                   address:crossoverFrequencyAddress
                       min:10.0
                       max:1000.0
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the lowReleaseTime.
    AUParameter *lowReleaseTimeAUParameter =
    [AUParameter parameter:@"lowReleaseTime"
                      name:@"Time (in seconds) to decay 60db in low-frequency band."
                   address:lowReleaseTimeAddress
                       min:0.0
                       max:10.0
                      unit:kAudioUnitParameterUnit_Seconds];
    // Create a parameter object for the midReleaseTime.
    AUParameter *midReleaseTimeAUParameter =
    [AUParameter parameter:@"midReleaseTime"
                      name:@"Time (in seconds) to decay 60db in mid-frequency band."
                   address:midReleaseTimeAddress
                       min:0.0
                       max:10.0
                      unit:kAudioUnitParameterUnit_Seconds];
    // Create a parameter object for the dampingFrequency.
    AUParameter *dampingFrequencyAUParameter =
    [AUParameter parameter:@"dampingFrequency"
                      name:@"Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60."
                   address:dampingFrequencyAddress
                       min:10.0
                       max:22050.0
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the equalizerFrequency1.
    AUParameter *equalizerFrequency1AUParameter =
    [AUParameter parameter:@"equalizerFrequency1"
                      name:@"Center frequency of second-order Regalia Mitra peaking equalizer section 1."
                   address:equalizerFrequency1Address
                       min:10.0
                       max:1000.0
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the equalizerLevel1.
    AUParameter *equalizerLevel1AUParameter =
    [AUParameter parameter:@"equalizerLevel1"
                      name:@"Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1"
                   address:equalizerLevel1Address
                       min:-100.0
                       max:10.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the equalizerFrequency2.
    AUParameter *equalizerFrequency2AUParameter =
    [AUParameter parameter:@"equalizerFrequency2"
                      name:@"Center frequency of second-order Regalia Mitra peaking equalizer section 2."
                   address:equalizerFrequency2Address
                       min:10.0
                       max:22050.0
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the equalizerLevel2.
    AUParameter *equalizerLevel2AUParameter =
    [AUParameter parameter:@"equalizerLevel2"
                      name:@"Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2"
                   address:equalizerLevel2Address
                       min:-100.0
                       max:10.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the dryWetMix.
    AUParameter *dryWetMixAUParameter =
    [AUParameter parameter:@"dryWetMix"
                      name:@"0 = all dry, 1 = all wet"
                   address:dryWetMixAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];


    // Initialize the parameter values.
    delayAUParameter.value = 60.0;
    crossoverFrequencyAUParameter.value = 200.0;
    lowReleaseTimeAUParameter.value = 3.0;
    midReleaseTimeAUParameter.value = 2.0;
    dampingFrequencyAUParameter.value = 6000.0;
    equalizerFrequency1AUParameter.value = 315.0;
    equalizerLevel1AUParameter.value = 0.0;
    equalizerFrequency2AUParameter.value = 1500.0;
    equalizerLevel2AUParameter.value = 0.0;
    dryWetMixAUParameter.value = 1.0;

    _kernel.setParameter(delayAddress,               delayAUParameter.value);
    _kernel.setParameter(crossoverFrequencyAddress,  crossoverFrequencyAUParameter.value);
    _kernel.setParameter(lowReleaseTimeAddress,      lowReleaseTimeAUParameter.value);
    _kernel.setParameter(midReleaseTimeAddress,      midReleaseTimeAUParameter.value);
    _kernel.setParameter(dampingFrequencyAddress,    dampingFrequencyAUParameter.value);
    _kernel.setParameter(equalizerFrequency1Address, equalizerFrequency1AUParameter.value);
    _kernel.setParameter(equalizerLevel1Address,     equalizerLevel1AUParameter.value);
    _kernel.setParameter(equalizerFrequency2Address, equalizerFrequency2AUParameter.value);
    _kernel.setParameter(equalizerLevel2Address,     equalizerLevel2AUParameter.value);
    _kernel.setParameter(dryWetMixAddress,           dryWetMixAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        delayAUParameter,
        crossoverFrequencyAUParameter,
        lowReleaseTimeAUParameter,
        midReleaseTimeAUParameter,
        dampingFrequencyAUParameter,
        equalizerFrequency1AUParameter,
        equalizerLevel1AUParameter,
        equalizerFrequency2AUParameter,
        equalizerLevel2AUParameter,
        dryWetMixAUParameter
    ]];

    parameterTreeBlock(ZitaReverb)
}

AUAudioUnitOverrides(ZitaReverb);

@end


