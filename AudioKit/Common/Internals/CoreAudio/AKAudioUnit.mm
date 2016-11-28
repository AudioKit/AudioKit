//
//  AKAudioUnit.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#import "AKAudioUnit.h"
#import <AVFoundation/AVFoundation.h>

@implementation AKAudioUnit

@synthesize parameterTree = _parameterTree;
@synthesize rampTime = _rampTime;
- (void)start {}
- (void)stop {}
- (BOOL)isPlaying {
    return NO;
}
- (BOOL)isSetUp {
    return NO;
}


- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {
        return nil;
    }
        
    self.maximumFramesToRender = 512;
    
    return self;
}

#pragma mark - AUAudioUnit Overrides

- (AUAudioUnitBusArray *)inputBusses {
    return _inputBusArray;
}
- (AUAudioUnitBusArray *)outputBusses {
    return _outputBusArray;
}


#pragma mark - AUAudioUnit Overrides

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    
    [self setUpParameterRamp];
    
    return YES;
}


- (void)setUpParameterRamp {
    /*
     While rendering, we want to schedule all parameter changes. Setting them
     off the render thread is not thread safe.
     */
    __block AUScheduleParameterBlock scheduleParameter = self.scheduleParameterBlock;
    
    // Ramp over rampTime in seconds.
    __block AUAudioFrameCount rampTime = AUAudioFrameCount(_rampTime * self.outputBus.format.sampleRate);
    
    self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        scheduleParameter(AUEventSampleTimeImmediate, rampTime, param.address, value);
    };
}


@end
