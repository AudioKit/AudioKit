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
    OCSEvent *oscillatingSound;
}
@property (nonatomic, strong) OscillatorOrchestra *orchestra;
@end


@implementation OscillatorConductor

@synthesize orchestra = _orchestra;

- (id)init {
    self = [super init];
    if (self) {
        _orchestra = [[OscillatorOrchestra alloc] init];
        [[OCSManager sharedOCSManager] runOrchestra:_orchestra];
    }
    return self;
}

- (void)setFrequency:(float)frequency {
    _orchestra.instrument.frequency.value = frequency;
    NSLog(@"setting frequency to %g", frequency);
}
- (void)setAmplitude:(float)amplitude {
    _orchestra.instrument.amplitude.value = amplitude;
    NSLog(@"setting amplitude to %g", amplitude);
}

- (void)startSound {
    oscillatingSound = [[OCSEvent alloc] initWithInstrument:_orchestra.instrument];
    [oscillatingSound trigger];
}
- (void)stopSound {
    OCSEvent *stopSound = [[OCSEvent alloc] initDeactivation:oscillatingSound afterDuration:0];
    [stopSound trigger];
}

@end
