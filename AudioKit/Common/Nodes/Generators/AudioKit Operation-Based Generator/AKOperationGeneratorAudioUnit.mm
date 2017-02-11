//
//  AKOperationGeneratorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKOperationGeneratorAudioUnit.h"
#import "AKOperationGeneratorDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKOperationGeneratorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKOperationGeneratorDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setSporth:(NSString *)sporth {
    _kernel.setSporth((char*)[sporth UTF8String]);
}

- (void)trigger:(int)trigger {
    _kernel.trigger(trigger);
}

- (NSArray *)parameters {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:14];
    for (int i = 0; i < 14; i++) {
        [temp setObject:[NSNumber numberWithFloat:_kernel.parameters[i]] atIndexedSubscript:i];
    }
    return [NSArray arrayWithArray:temp];
}

- (void)setParameters:(NSArray *)parameters {
    float params[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    for (int i = 0; i < parameters.count; i++) {
        params[i] =[parameters[i] floatValue];
    }
    _kernel.setParameters(params);
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

- (void)createParameters {
    standardSetup(OperationGenerator)
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];
	parameterTreeBlock(OperationGenerator)
}

AUAudioUnitGeneratorOverrides(OperationGenerator)

@end


