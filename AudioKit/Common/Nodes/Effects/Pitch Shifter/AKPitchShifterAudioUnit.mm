//
//  AKPitchShifterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKPitchShifterAudioUnit.h"
#import "AKPitchShifterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPitchShifterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPitchShifterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setShift:(float)shift {
    _kernel.setShift(shift);
}
- (void)setWindowSize:(float)windowSize {
    _kernel.setWindowSize(windowSize);
}
- (void)setCrossfade:(float)crossfade {
    _kernel.setCrossfade(crossfade);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(PitchShifter)

    // Create a parameter object for the shift.
    AUParameter *shiftAUParameter = [AUParameter parameter:@"shift"
                                                      name:@"Pitch shift (in semitones)"
                                                   address:shiftAddress
                                                       min:-24.0
                                                       max:24.0
                                                      unit:kAudioUnitParameterUnit_RelativeSemiTones];
    // Create a parameter object for the windowSize.
    AUParameter *windowSizeAUParameter = [AUParameter parameter:@"windowSize"
                                                           name:@"Window size (in samples)"
                                                        address:windowSizeAddress
                                                            min:0.0
                                                            max:10000.0
                                                           unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the crossfade.
    AUParameter *crossfadeAUParameter = [AUParameter parameter:@"crossfade"
                                                          name:@"Crossfade (in samples)"
                                                       address:crossfadeAddress
                                                           min:0.0
                                                           max:10000.0
                                                          unit:kAudioUnitParameterUnit_Hertz];
    // Initialize the parameter values.
    shiftAUParameter.value = 0;
    windowSizeAUParameter.value = 1024;
    crossfadeAUParameter.value = 512;

    _kernel.setParameter(shiftAddress,      shiftAUParameter.value);
    _kernel.setParameter(windowSizeAddress, windowSizeAUParameter.value);
    _kernel.setParameter(crossfadeAddress,  crossfadeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        shiftAUParameter,
        windowSizeAUParameter,
        crossfadeAUParameter
    ]];


	parameterTreeBlock(PitchShifter)
}

AUAudioUnitOverrides(PitchShifter);

@end


