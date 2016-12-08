//
//  AKTesterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTesterAudioUnit.h"
#import "AKTesterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKTesterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKTesterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setSamples:(int)samples {
    _kernel.setSamples(samples);
}

- (NSString *)getMD5 {
    return _kernel.getMD5();
}

- (int)getSamples {
    return _kernel.getSamples();
}

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (void)createParameters {
    standardSetup(Tester)
    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];
    parameterTreeBlock(Tester)
}

AUAudioUnitOverrides(Tester)

@end


