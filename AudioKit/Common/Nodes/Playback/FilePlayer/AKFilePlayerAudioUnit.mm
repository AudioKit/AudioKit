//
//  AKFilePlayerAudioUnit.mm
//  AudioKit For iOS
//
//  Created by Bang Means Do It on 28/03/2017.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKFilePlayerAudioUnit.h"
#import "AKFilePlayerDSPKernel.hpp"
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKFilePlayerAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFilePlayerDSPKernel _kernel;
    
    BufferedInputBus _inputBus;
}

@synthesize parameterTree = _parameterTree;

standardKernelPassthroughs()

- (void)createParameters {
    
    standardSetup(FilePlayer);
    
    parameterTreeBlock(FilePlayer);
}

AUAudioUnitGeneratorOverrides(FilePlayer)

// Custom set up
- (void)setUpAudioInput:(CFURLRef)url {
    _kernel.setURL(url);
    
    _kernel.setCurrentTimeUpdatedCallback([=] (float currentTime) -> void {
    });
    
    _kernel.setSectionEndReachedCallback([=] (void) -> void {
        NSLog(@"Loop End");
    });
}

- (void)setSampleTimeStartOffset:(int32_t)offset {
    if(offset >= 0) {
        _kernel.setSampleTimeStartOffset(offset);
    } else {
        _kernel.setSampleTimeDelayOffset(abs(offset));
    }
}

- (void)prepareToPlay {
    _kernel.prepareToPlay();
}

- (float)fileLengthInSeconds {
    return _kernel.fileLengthInSeconds();
}

- (void)prepareForOfflineRender {
    _kernel.prepareForOfflineRender();
}

@end
