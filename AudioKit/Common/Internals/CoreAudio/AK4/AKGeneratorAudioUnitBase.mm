//
//  AKGeneratorAudioUnitBase.mm
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKGeneratorAudioUnitBase.h"

@implementation AKGeneratorAudioUnitBase

- (void)setupWaveform:(int)size {
    ((AKDSPBase *)self.dsp)->setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    ((AKDSPBase *)self.dsp)->setWaveformValue(index, value);
}
- (void)setupIndividualWaveform:(UInt32)waveform size:(int)size {
    ((AKDSPBase *)self.dsp)->setupIndividualWaveform(waveform, (uint32_t)size);
}
- (void)setIndividualWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index {
    ((AKDSPBase *)self.dsp)->setIndividualWaveformValue(waveform, index, value);
}
- (void)trigger {
    ((AKDSPBase *)self.dsp)->trigger();
}
- (void)triggerFrequency:(float)frequency amplitude:(float)amplitude {
    ((AKDSPBase *)self.dsp)->triggerFrequencyAmplitude(frequency, amplitude);
}
- (void)triggerType:(UInt8)type amplitude:(float)amplitude {
    ((AKDSPBase *)self.dsp)->triggerTypeAmplitude(type, amplitude);
}
- (void)setupAudioFileTable:(float *)data size:(UInt32)size {
    ((AKDSPBase *)self.dsp)->setUpTable(data, size);
}
- (void)setPartitionLength:(int)partitionLength {
    ((AKDSPBase *)self.dsp)->setPartitionLength(partitionLength);
}
- (void)initConvolutionEngine {
    ((AKDSPBase *)self.dsp)->initConvolutionEngine();
}

-(BOOL)shouldAllocateInputBus {
    return false;
}

@end

