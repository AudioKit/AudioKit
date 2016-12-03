//
//  AKBitCrusherAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKBitCrusherAudioUnit.h"
#import "AKBitCrusherDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKBitCrusherAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKBitCrusherDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setBitDepth:(float)bitDepth {
    _kernel.setBitDepth(bitDepth);
}
- (void)setSampleRate:(float)sampleRate {
    _kernel.setSampleRate(sampleRate);
}


- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (BOOL)isPlaying {
    return _kernel.started;
}

- (BOOL)isSetUp {
    return _kernel.resetted;
}

- (void)createParameters {
    
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                                  channels:AKSettings.numberOfChannels];

    // Create a DSP kernel to handle the signal processing.
    _kernel.init(defaultFormat.channelCount, defaultFormat.sampleRate);

        // Create a parameter object for the bitDepth.
    AUParameter *bitDepthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"bitDepth"
                                              name:@"Bit Depth"
                                           address:bitDepthAddress
                                               min:1
                                               max:24
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the sampleRate.
    AUParameter *sampleRateAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"sampleRate"
                                              name:@"Sample Rate (Hz)"
                                           address:sampleRateAddress
                                               min:1.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    bitDepthAUParameter.value = 8;
    sampleRateAUParameter.value = 10000;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(bitDepthAddress,   bitDepthAUParameter.value);
    _kernel.setParameter(sampleRateAddress, sampleRateAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        bitDepthAUParameter,
        sampleRateAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKBitCrusherDSPKernel *bitcrusherKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        bitcrusherKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return bitcrusherKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case bitDepthAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case sampleRateAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

    _inputBus.init(defaultFormat, 8);
    self.inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                 busType:AUAudioUnitBusTypeInput
                                                                  busses:@[_inputBus.bus]];
}

AUAudioUnitOverrides(BitCrusher);

@end


