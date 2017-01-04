//
//  AKAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#import "AKAudioUnit.h"
#import <AVFoundation/AVFoundation.h>

@implementation AKAudioUnit {
    AUAudioUnitBusArray *_outputBusArray;
}

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

-(double)rampTime {
    return _rampTime;
}

-(void)setRampTime:(double)rampTime {
    if (_rampTime == rampTime) { return; }
    _rampTime = rampTime;
    [self setUpParameterRamp];
}

- (void)createParameters {}

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {
        return nil;
    }
    
    // Initialize a default format for the busses.
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100
                                                                        channels:2];
    
    [self createParameters];
    
    // Create the output busses.
    self.outputBus = [[AUAudioUnitBus alloc] initWithFormat:self.defaultFormat error:nil];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[self.outputBus]];
    
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

//
// Not currently achievable in Swift because you cannot set self in a class constructor
//

@implementation AUParameter(Ext)

-(instancetype)init:(NSString *)identifier
               name:(NSString *)name
            address:(AUParameterAddress)address
                min:(AUValue)min
                max:(AUValue)max
               unit:(AudioUnitParameterUnit)unit {

    return self = [AUParameterTree createParameterWithIdentifier:identifier
                                                            name:name
                                                         address:address
                                                             min:min
                                                             max:max
                                                            unit:unit
                                                        unitName:nil
                                                           flags:0
                                                    valueStrings:nil
                                             dependentParameters:nil];
}

+(instancetype)parameter:(NSString *)identifier
                    name:(NSString *)name
                 address:(AUParameterAddress)address
                     min:(AUValue)min
                     max:(AUValue)max
                    unit:(AudioUnitParameterUnit)unit {
    return [[AUParameter alloc] init:identifier
                                name:name
                             address:address
                                 min:min
                                 max:max
                                unit:unit];
}

+(instancetype)frequency:(NSString *)identifier
                    name:(NSString *)name
                 address:(AUParameterAddress)address {
    return [[AUParameter alloc] init:identifier
                                name:name
                             address:address
                                 min:20
                                 max:22050
                                unit:kAudioUnitParameterUnit_Hertz];
}
@end
