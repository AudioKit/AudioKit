//
//  AKFMOscillator.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFMOscillator.h"

@implementation AKFMOscillator
{
    AKManager *manager;
    AKTable *_waveform;
    float out;
}

- (instancetype)init
{
    NSLog(@"initing fmoscillator");
    if ([super init]) {
        manager = [AKManager sharedManager];
        [self create];
    }
    return self;
    
}

- (instancetype)initWithWaveform:(AKTable *)waveform
                    baseFrequency:(AKParameter *)baseFrequency
                carrierMultiplier:(AKParameter *)carrierMultiplier
             modulatingMultiplier:(AKParameter *)modulatingMultiplier
                  modulationIndex:(AKParameter *)modulationIndex
                        amplitude:(AKParameter *)amplitude
{
    self = [super init];
    if (self) {
        manager = [AKManager sharedManager];
        _waveform = waveform;
        [self create];
        [baseFrequency bind:&_fosc->freq];
        [carrierMultiplier bind:&_fosc->car];
        [modulatingMultiplier bind:&_fosc->mod];
        [modulationIndex bind:&_fosc->indx];
        [amplitude bind:&_fosc->amp];
    }
    return self;
}

- (instancetype)initWithBaseFrequency:(AKParameter *)baseFrequency
                    carrierMultiplier:(AKParameter *)carrierMultiplier
                 modulatingMultiplier:(AKParameter *)modulatingMultiplier
                      modulationIndex:(AKParameter *)modulationIndex
                            amplitude:(AKParameter *)amplitude
{
    AKTable *waveform = [[AKTable alloc] init];
    return [self initWithWaveform:waveform
                    baseFrequency:baseFrequency
                carrierMultiplier:carrierMultiplier
             modulatingMultiplier:modulatingMultiplier
                  modulationIndex:modulationIndex
                        amplitude:amplitude];
}

- (void)create
{
    sp_fosc_create(&_fosc);
    sp_fosc_init(manager.data, _fosc, _waveform.table);
    out = 0;
// This could change..
    self.value = &out;
}

- (float)compute
{
    sp_fosc_compute(manager.data, _fosc, NULL, &out);
    *self.value = out;
    return out;
}

- (void)destroy
{
    [_waveform destroy];
    sp_fosc_destroy(&_fosc);
    [manager destroy];
}

@end
