//
//  AKMandolinAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKMandolinAudioUnit.h"
#import "AKMandolinDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKMandolinAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMandolinDSPKernel _kernel;
    BufferedInputBus _inputBus;
}

@synthesize parameterTree = _parameterTree;

- (void)setDetune:(float)detune {
    _kernel.setDetune(detune);
}
- (void)setBodySize:(float)bodySize {
    _kernel.setBodySize(bodySize);
}

- (void)setFrequency:(float)frequency course:(int)course {
    _kernel.setFrequency(frequency, course);
}
- (void)pluckCourse:(int)course position:(float)position velocity:(int)velocity {
    _kernel.pluck(course, position, velocity);
}
- (void)muteCourse:(int)course {
    _kernel.mute(course);
}

- (BOOL)isSetUp {
    return _kernel.resetted;
}

- (void)createParameters {

    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];
    
    // Create a DSP kernel to handle the signal processing.
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);

    // Create a parameter object for the detune.
    AUParameter *detuneAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"detune"
                                              name:@"Detune"
                                           address:detuneAddress
                                               min:0.0001
                                               max:100.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the body size.
    AUParameter *bodySizeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"bodySize"
                                              name:@"Body size"
                                           address:bodySizeAddress
                                               min:0
                                               max:10
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

    // Initialize the parameter values.
    detuneAUParameter.value = 1.0;
    bodySizeAUParameter.value = 1.0;
    
    self.rampTime = AKSettings.rampTime;
    
    _kernel.setParameter(detuneAddress,        detuneAUParameter.value);
    _kernel.setParameter(bodySizeAddress,      bodySizeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        detuneAUParameter,
        bodySizeAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKMandolinDSPKernel *mandolinKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        mandolinKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return mandolinKernel->getParameter(param.address);
    };

    _inputBus.init(self.defaultFormat, 8);
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                busType:AUAudioUnitBusTypeInput
                                                                 busses:@[_inputBus.bus]];
}

AUAudioUnitGeneratorOverrides(Mandolin)


@end


