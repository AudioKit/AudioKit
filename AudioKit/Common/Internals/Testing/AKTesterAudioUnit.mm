// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKTesterAudioUnit.h"
#import "AKTesterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKTesterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKTesterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (int)samples {
    return _kernel.getSamples();
}

- (void)setSamples:(int)samples {
    _kernel.setSamples(samples);
}

- (NSString *)md5 {
    return _kernel.getMD5();
}

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (void)createParameters {
    standardSetup(Tester)
    _parameterTree = [AUParameterTree treeWithChildren:@[]];
    parameterTreeBlock(Tester)
}

AUAudioUnitOverrides(Tester)

@end


