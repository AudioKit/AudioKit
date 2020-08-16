// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKCallbackInstrumentAudioUnit.h"
#import "AKCallbackInstrumentDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKCallbackInstrumentAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKCallbackInstrumentDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)destroy {
    _kernel.destroy();
}

-(void)setCallback:(AKCMIDICallback)callback {
    _kernel.callback = callback;
}

standardKernelPassthroughs()

- (void)createParameters {

    standardGeneratorSetup(CallbackInstrument)

    // Create the parameter tree.
    _parameterTree = [AUParameterTree treeWithChildren:@[]];

    parameterTreeBlock(CallbackInstrument)
}

AUAudioUnitGeneratorOverrides(CallbackInstrument)

@end


