//
//  AKAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
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

-(AUImplementorValueProvider)getter {
  return _parameterTree.implementorValueProvider;
}

-(AUImplementorValueObserver)setter {
  return _parameterTree.implementorValueObserver;
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
    return [AUParameter parameter:identifier
                             name:name
                          address:address
                              min:20
                              max:22050
                             unit:kAudioUnitParameterUnit_Hertz];
}
@end

@implementation AUParameterTree(Ext)

+(instancetype)tree:(NSArray<AUParameterNode *> *)children {
    AUParameterTree* tree = [AUParameterTree createTreeWithChildren:children];
    if (tree == nil) {
        return nil;
    }

    tree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
      AUValue value = valuePtr == nil ? param.value : *valuePtr;
      return [NSString stringWithFormat:@"%.3f", value];

    };
    return tree;

}
@end



@implementation AVAudioNode(Ext)
-(instancetype)initWithComponent:(AudioComponentDescription)component {
		self = [self init];
		__block AVAudioNode * __strong * _this = &self;

  [AVAudioUnit instantiateWithComponentDescription:component
                                           options:0
                                 completionHandler:^(__kindof AVAudioUnit * _Nullable audioUnit,
                                                     NSError * _Nullable error) {

                                   *_this = audioUnit;
                                 }];
  return self;
}
@end
