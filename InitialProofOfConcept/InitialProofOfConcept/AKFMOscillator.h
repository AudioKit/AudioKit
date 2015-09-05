//
//  AKFMOscillator.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

//#import <Foundation/Foundation.h>

#import "AKParameter.h"
#import "AKTable.h"

@interface AKFMOscillator : AKParameter

- (instancetype)initWithWaveform:(AKTable *)waveform
                   baseFrequency:(AKParameter *)baseFrequency
               carrierMultiplier:(AKParameter *)carrierMultiplier
            modulatingMultiplier:(AKParameter *)modulatingMultiplier
                 modulationIndex:(AKParameter *)modulationIndex
                       amplitude:(AKParameter *)amplitude;

- (instancetype)initWithBaseFrequency:(AKParameter *)baseFrequency
                    carrierMultiplier:(AKParameter *)carrierMultiplier
                 modulatingMultiplier:(AKParameter *)modulatingMultiplier
                      modulationIndex:(AKParameter *)modulationIndex
                            amplitude:(AKParameter *)amplitude;

@property (nonatomic) sp_fosc *fosc;

@end
