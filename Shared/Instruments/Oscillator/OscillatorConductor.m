//
//  OscillatorConductor.m
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorConductor.h"
#import "OCSManager.h"
#import "OscillatorOrchestra.h"

@interface OscillatorConductor () {
    OCSEvent *startEvent;
    OscillatorOrchestra *orchestra;
}
@end


@implementation OscillatorConductor

- (id)init {
    self = [super init];
    if (self) {
        orchestra = [[OscillatorOrchestra alloc] init];
        [[OCSManager sharedOCSManager] runOrchestra:orchestra];
    }
    return self;
}

- (void)setFrequency:(float)frequency {
    orchestra.instrument.frequency.value = frequency;
}
- (void)setAmplitude:(float)amplitude {
    orchestra.instrument.amplitude.value = amplitude;
}

- (void)startSound {
    if (!startEvent) {
        startEvent = [[OCSEvent alloc] initWithInstrument:orchestra.instrument];
        [startEvent trigger];
    }
}
- (void)stopSound {
    if (startEvent) {
        [[[OCSEvent alloc] initDeactivation:startEvent afterDuration:0] trigger];
        startEvent = nil;
    }
}

- (void)quit {
    [self stopSound];
    [[OCSManager sharedOCSManager] stop];
}

@end
