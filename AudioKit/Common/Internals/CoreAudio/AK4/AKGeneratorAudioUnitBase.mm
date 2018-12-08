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

-(BOOL)shouldAllocateInputBus {
    return false;
}

@end

