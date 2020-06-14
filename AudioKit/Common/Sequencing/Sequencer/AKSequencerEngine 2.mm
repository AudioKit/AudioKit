//
//  AKSequencerEngine.mm
//  AudioKit
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
#import <AudioKit/AudioKit-Swift.h>

#import "AKSequencerEngine.h"
#import "AKSequencerDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKSequencerEngine
{
    AKSequencerEngineDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setTempo:(double)bpm {
    _kernel.setTempo(bpm);
}

- (double)tempo {
    return _kernel.tempo;
}

- (void)setLength:(double)length {
    _kernel.length = length;
}

- (double)length {
    return _kernel.length;
}

- (void)setMaximumPlayCount:(double)maximumPlayCount {
    _kernel.maximumPlayCount = maximumPlayCount;
}

- (double)maximumPlayCount {
    return _kernel.maximumPlayCount;
}

- (double)currentPosition {
    return _kernel.currentPositionInBeats();
}

- (void)setLoopEnabled:(bool)loopEnabled {
    _kernel.loopEnabled = loopEnabled;
}

- (bool)loopEnabled {
    return _kernel.loopEnabled;
}

- (void)setTarget:(AudioUnit)target {
    _kernel.setTargetAU(target);
}

- (void)addMIDIEvent:(uint8_t)status
               data1:(uint8_t)data1
               data2:(uint8_t)data2
                beat:(double)beat {
    _kernel.addMIDIEvent(status, data1, data2, beat);
}

- (void)addMIDINote:(uint8_t)number
           velocity:(uint8_t)velocity
               beat:(double)beat
           duration:(double)duration {
    _kernel.addMIDINote(number, velocity, beat, duration);
}

- (void)removeEvent:(double)beat {
    _kernel.removeEventAt(beat);
}

- (void)removeNote:(double)beat {
    _kernel.removeNoteAt(beat);
}

- (void)setLoopCallback:(AKCCallback)callback {
    _kernel.loopCallback = callback;
}

- (void)clear {
    _kernel.clear();
}

- (void)stopPlayingNotes {
    _kernel.stopPlayingNotes();
}

- (void)rewind {
    _kernel.seekTo(0.0);
}

- (void)seekTo:(double)seekPosition {
    _kernel.seekTo(seekPosition);
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

- (void)setShouldBypassEffect:(BOOL)shouldBypassEffect {
    if (shouldBypassEffect) {
        _kernel.stop();
    } else {
        _kernel.start();
    }
}

- (void)createParameters {
    self.rampDuration = AKSettings.rampDuration;
    self.defaultFormat = AKSettings.audioFormat;
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);
    _outputBusBuffer.init(self.defaultFormat, 2);
    self.outputBus = _outputBusBuffer.bus;
    self.outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeOutput busses:@[self.outputBus]];

    // Create a parameter object for the start.
    AUParameter *startPointAUParameter = [AUParameter parameterWithIdentifier:@"startPoint"
                                                                         name:@"startPoint"
                                                                      address:startPointAddress
                                                                          min:0
                                                                          max:1
                                                                         unit:kAudioUnitParameterUnit_Generic];
    // Initialize the parameter values.
    startPointAUParameter.value = 0;

    _kernel.setParameter(startPointAddress,   startPointAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree treeWithChildren:@[
                          startPointAUParameter
    ]];

    __block AKSequencerEngineDSPKernel *blockKernel = &_kernel;
    self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        blockKernel->setParameter(param.address, value);
    };
    self.parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return blockKernel->getParameter(param.address);
    };
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    _outputBusBuffer.allocateRenderResources(self.maximumFramesToRender);
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel.reset();
    return YES;
}

- (void)deallocateRenderResources {
    _outputBusBuffer.deallocateRenderResources();
    [super deallocateRenderResources];
}

- (AUInternalRenderBlock)internalRenderBlock {
    __block AKSequencerEngineDSPKernel *state = &_kernel;
    return ^AUAudioUnitStatus (AudioUnitRenderActionFlags *actionFlags,
                               const AudioTimeStamp *timestamp,
                               AVAudioFrameCount frameCount,
                               NSInteger outputBusNumber,
                               AudioBufferList *outputData,
                               const AURenderEvent *realtimeEventListHead,
                               AURenderPullInputBlock pullInputBlock) {
               _outputBusBuffer.prepareOutputBufferList(outputData, frameCount, true);
               state->setBuffer(outputData);
               state->processWithEvents(timestamp, frameCount, realtimeEventListHead);
               return noErr;
    };
}

@end
